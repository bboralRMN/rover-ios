//
//  EventManager.swift
//  Rover
//
//  Created by Sean Rucker on 2016-11-24.
//  Copyright © 2016 Rover Labs Inc. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let didStartUpload = Notification.Name("io.rover.didStartUpload")
    static let didFinishUpload = Notification.Name("io.rover.didFinishUpload")
}

class EventManager {
    
    let config: EventManagerConfiguration
    
    let serialQueue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()
    
    var events = [Event]()
    
    var uploadBatch: [Event]?
    var uploadTask: URLSessionUploadTask?
    
    init(configuration: EventManagerConfiguration) {
        self.config = configuration
    }
    
    func trackEvent(name: String, attributes: JSON? = nil) {
        
        // Create the event on current thread so the timestamp is more accurate
        let event = Event(name: name, attributes: attributes)
        
        serialQueue.addOperation {
            self.add(event: event)
            self.persistEvents()
            self.sendEvents(minBatchSize: self.config.sendAt)
        }
    }
    
    /*
     * The following events access/modify the events array and/or the batchRequest property
     * on separate threads and should only be called from an operation added to the serial
     * queue.
     */
    
    func add(event: Event) {
        if events.count == config.maxTotalEvents {
            events.remove(at: 0)
        }
        
        events.append(event)
    }
    
    func persistEvents() {
        // TODO: Persist queue
    }
    
    func sendEvents(minBatchSize: Int = 1) {
        guard events.count > 0 else {
            print("No events to flush")
            return
        }
        
        guard events.count >= minBatchSize else {
            print("\(events.count) events found, will send at \(minBatchSize)")
            return
        }
        
        guard uploadTask == nil else {
            print("Event sending already in-progress")
            return
        }
        
        let eventsToSend = Array(events.prefix(config.maxBatchSize))
        print("Sending \(eventsToSend.count) events")
        
        let body = [
            "events": eventsToSend.map { event in
                return event.serialize()
            }
        ]
        
        uploadTask = config.uploadClient.upload(url: config.uploadURL, body: body) { success, retry in
            self.serialQueue.addOperation {
                if !retry {
                    self.remove(events: eventsToSend)
                    self.persistEvents()
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .didFinishUpload, object: self, userInfo: [
                        "events": eventsToSend,
                        "success": success,
                        "retry": retry
                        ])
                }
                self.uploadTask = nil
            }
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .didStartUpload, object: self, userInfo: ["events": eventsToSend])
        }
    }
    
    func remove(events eventsToRemove: [Event]) {
        events = events.filter { event in
            return !eventsToRemove.contains() { $0.eventId == event.eventId }
        }
    }
}

protocol EventManagerConfiguration {

    var sendAt: Int { get }
    
    var maxBatchSize: Int { get }
    
    var maxTotalEvents: Int { get }
    
    var uploadURL: URL { get }
    
    var uploadClient: HTTPUploadClient { get }
}
