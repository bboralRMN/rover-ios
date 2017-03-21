//
//  EventBatch.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData

struct EventBatch {
    
    let events: [Event]
    
    let authHeaders: [AuthHeader]?
    
    init(events: [Event]? = nil, authHeaders: [AuthHeader]? = nil) {
        self.events = events ?? [Event]()
        self.authHeaders = authHeaders
    }
}

extension EventBatch {
    
    var count: Int {
        return events.count
    }
    
    var first: Event? {
        return events.first
    }
    
    var last: Event? {
        return events.last
    }
    
    var operation: TrackEventsMutation {
        let events = self.events.map { event -> TrackEventsMutation.Event in
            var attributes = event.attributes ?? JSON()
            attributes["context"] = event.context
            return TrackEventsMutation.Event(timestamp: event.timestamp,
                                             name: event.name,
                                             attributes: attributes)
        }
        
        return TrackEventsMutation(events: events)
    }
    
    func contains(_ event: Event) -> Bool {
        return events.contains() { $0.eventId == event.eventId }
    }
}
