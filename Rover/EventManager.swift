//
//  EventManager.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-03.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverContext
import RoverData
import RoverLogger

// MARK: ApplicationType

protocol ApplicationType {
    
    func beginBackgroundTask(expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier
    
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier)
}

extension UIApplication: ApplicationType { }

// MARK: NotificationCenterType

protocol NotificationCenterType {
    
    @discardableResult func addObserver(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NSObjectProtocol
}

extension NotificationCenter: NotificationCenterType { }

// MARK: Notification

extension Notification.Name {
    static let didTrackEvent = Notification.Name("io.rover.didTrackEvent")
}

// MARK: EventManager

public class EventManager {
    
    let serialQueue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()
    
    let apiClient: EventsAPIClient
    
    let flushAt: Int
    
    let flushInterval: Double
    
    let contextProvider: ContextProvider?
    
    let application: ApplicationType
    
    var eventQueue: EventQueue
    
    var uploadTask: HTTPTask?
    
    var backgroundTask = UIBackgroundTaskInvalid
    
    var timer: Timer?
    
    public convenience init(flushAt: Int,
                            flushInterval: Double,
                            maxQueueSize: Int,
                            maxBatchSize: Int,
                            apiClient: EventsAPIClient,
                            contextProvider: ContextProvider?) {
        
        self.init(flushAt: flushAt,
                  flushInterval: flushInterval,
                  maxQueueSize: maxQueueSize,
                  maxBatchSize: maxBatchSize,
                  apiClient: apiClient,
                  contextProvider: contextProvider,
                  application: nil)
    }
    
    init(flushAt: Int,
         flushInterval: Double,
         maxQueueSize: Int,
         maxBatchSize: Int,
         apiClient: EventsAPIClient,
         contextProvider: ContextProvider?,
         application: ApplicationType? = nil,
         notificationCenter: NotificationCenterType? = nil) {
        
        self.flushAt = flushAt
        self.flushInterval = flushInterval
        self.eventQueue = EventQueue(maxQueueSize: maxQueueSize, maxBatchSize: maxBatchSize)
        self.apiClient = apiClient
        self.contextProvider = contextProvider
        self.application = application ?? UIApplication.shared
        
        let notificationCenter = notificationCenter ?? NotificationCenter.default
        
        notificationCenter.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: serialQueue) { _ in
            self.startBackgroundTask()
            self.sendEvents()
        }
        
        notificationCenter.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: serialQueue) { _ in
            self.startFlushTimer()
        }
        
        notificationCenter.addObserver(forName: .UIApplicationWillResignActive, object: nil, queue: serialQueue) { _ in
            self.stopFlushTimer()
        }
    }
    
    public func trackEvent(name: String, attributes: Attributes? = nil) {
        
        // Create the event on the current thread so the context and timestamp are more accurate
        let context = contextProvider?.capture()
        let event = Event(name: name, attributes: attributes, context: context)
        
        serialQueue.addOperation {
            self.addEvent(event: event)
            self.persistEvents()
            self.sendEvents(minBatchSize: self.flushAt)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didTrackEvent, object: self, userInfo: [
                    "event": event
                    ])
            }
        }
    }
    
    public func flushEvents() {
        serialQueue.addOperation {
            self.sendEvents()
        }
    }
    
    // The following methods access or modify the variable event manager properties and should only be called from an operation added to the serial queue.
    
    func startFlushTimer() {
        stopFlushTimer()
        
        guard flushInterval > 0.0 else {
            return
        }
        
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: flushInterval, repeats: true) { _ in
                self.serialQueue.addOperation {
                    self.sendEvents()
                }
            }
        }
    }
    
    func stopFlushTimer() {
        guard let timer = timer else {
            return
        }
        
        timer.invalidate()
        self.timer = nil
    }
    
    func startBackgroundTask() {
        endBackgroundTask()
        
        backgroundTask = application.beginBackgroundTask() {
            self.serialQueue.addOperation {
                self.endBackgroundTask()
            }
        }
    }
    
    func endBackgroundTask() {
        if (backgroundTask != UIBackgroundTaskInvalid) {
            application.endBackgroundTask(backgroundTask)
            backgroundTask = UIBackgroundTaskInvalid
        }
    }
    
    func addEvent(event: Event) {
        eventQueue.add(event: event)
    }
    
    func removeEvents(batch: EventBatch) {
        eventQueue.remove(batch: batch)
    }
    
    func persistEvents() {
        // TODO: Persist eventQueue to file
    }
    
    func sendEvents(minBatchSize: Int = 1) {
        guard uploadTask == nil else {
            logger.debug("Event sending already in-progress")
            return
        }
        
        let batch = eventQueue.nextBatch(minSize: minBatchSize)
        
        guard batch.count > 0 else {
            logger.debug("Nothing to send – less than \(minBatchSize) events in the queue")
            endBackgroundTask()
            return
        }
        
        uploadTask = apiClient.trackEventsTask(events: batch) { result in
            self.serialQueue.addOperation {
                switch result {
                case let .error(_, shouldRetry):
                    if !shouldRetry {
                        fallthrough
                    }
                case .success:
                    self.removeEvents(batch: batch)
                    self.persistEvents()
                }
                
                switch result {
                case let .error(error, shouldRetry):
                    if let error = error {
                        logger.error(error.localizedDescription)
                    }
                    
                    let nextSteps = shouldRetry ? "Will retry" : "Discarding batch"
                    logger.error("Failed to upload event batch: \(nextSteps)")
                case .success:
                    logger.debug("Successfully uploaded \(batch.count) events")
                }
                
                self.uploadTask = nil
                self.endBackgroundTask()
            }
        }
        uploadTask?.resume()
    }
}
