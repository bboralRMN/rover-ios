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
    
    let flushAt: Int
    
    let maxBatchSize: Int
    
    let maxQueueSize: Int
    
    let uploadURL: URL
    
    let uploadClient: HTTPUploadClient
    
    let serialQueue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()
    
    var events = [Event]()
    
    var uploadBatch: [Event]?
    var uploadTask: HTTPSessionUploadTask?
    
    init(flushAt: Int? = nil, maxBatchSize: Int? = nil, maxQueueSize: Int? = nil, uploadURL: URL? = nil, uploadClient: HTTPUploadClient? = nil) {
        self.flushAt = flushAt ?? 20
        self.maxBatchSize = maxBatchSize ?? 100
        self.maxQueueSize = maxQueueSize ?? 1000
        self.uploadURL = uploadURL ?? URL(string: "http://example.com")!
        self.uploadClient = uploadClient ?? HTTPClient()
    }
    
    func trackEvent(name: String, attributes: JSON? = nil) {
        
        // Create the event on current thread so the timestamp is more accurate
        let event = Event(name: name, attributes: attributes)
        
        serialQueue.addOperation {
            self.add(event: event)
            self.persistEvents()
            self.sendEvents(minBatchSize: self.flushAt)
        }
    }
    
    /*
     * The following events access/modify the events array and/or the batchRequest property
     * on separate threads and should only be called from an operation added to the serial
     * queue.
     */
    
    func add(event: Event) {
        if events.count == maxQueueSize {
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
            print("\(events.count) events is less than the minimum batch size of \(minBatchSize)")
            return
        }
        
        guard uploadTask == nil else {
            print("Event sending already in-progress")
            return
        }
        
        let eventsToSend = Array(events.prefix(maxBatchSize))
        print("Sending \(eventsToSend.count) events")
        
        let body = [
            "events": eventsToSend.map { event in
                return event.serialize()
            }
        ]
        
        uploadTask = uploadClient.upload(url: uploadURL, body: body) { success, retry in
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
