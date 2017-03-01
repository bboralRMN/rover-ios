//
//  EventQueue.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

struct EventQueue {
    var maxQueueSize: Int
    var maxBatchSize: Int
    var events = [Event]()
}

extension EventQueue {
    
    var count: Int {
        return events.count
    }
    
    init(maxQueueSize: Int, maxBatchSize: Int) {
        self.maxQueueSize = maxQueueSize
        self.maxBatchSize = maxBatchSize
    }
    
    mutating func add(event: Event) {
        if events.count == maxQueueSize {
            events.remove(at: 0)
        }
        
        events.append(event)
    }
    
    mutating func remove(batch: EventBatch) {
        events = events.filter { event in
            return !batch.contains() { $0.eventId == event.eventId }
        }
    }
    
    func nextBatch(minSize: Int) -> EventBatch {
        guard events.count > 0, events.count >= minSize else {
            return EventBatch()
        }
        
        return EventBatch(events.prefix(maxBatchSize))
    }
}
