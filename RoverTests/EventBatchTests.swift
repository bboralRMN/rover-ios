//
//  EventBatchTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-21.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData

@testable import Rover

class EventBatchTests: XCTestCase {
    
    func testOperation() {
        let events = [
            Event(name: "lorem", attributes: ["ipsum": "sit"], context: ["dolor": "amet"]),
            Event(name: "amet", attributes: ["lorem": "ipsum"], context: ["sit": "dolor"]),
            Event(name: "dolor", attributes: ["amet": "lorem"], context: ["ipsum": "sit"])
        ]
        
        let batch = EventBatch(events: events)
        let operation = batch.operation
        
        for (offset, event) in operation.events.enumerated() {
            let original = events[offset]
            
            switch event.timestamp.compare(original.timestamp) {
            case .orderedSame:
                break
            default:
                XCTFail()
            }
            
            XCTAssertEqual(event.name, original.name)
            
            for (key, value) in original.attributes! {
                XCTAssertEqual(event.attributes![key] as! String, value as! String)
            }
            
            let context = event.attributes!["context"] as! JSON
            
            for (key, value) in original.context! {
                XCTAssertEqual(context[key] as! String, value as! String)
            }
        }
    }
    
    func testContains() {
        let events = [
            Event(name: "Test"),
            Event(name: "Test"),
            Event(name: "Test"),
            Event(name: "Test"),
            Event(name: "Test")
        ]
        
        let batch = EventBatch(events: events)
        XCTAssertTrue(batch.contains(events.first!))
        XCTAssertTrue(batch.contains(events.last!))
        
        let otherEvent = Event(name: "Test")
        XCTAssertFalse(batch.contains(otherEvent))
    }
}


//var operation: TrackEventsMutation {
//    let events = self.events.map { event in
//        return TrackEventsMutation.Event(timestamp: event.timestamp,
//                                         name: event.name,
//                                         attributes: event.attributes)
//    }
//    
//    return TrackEventsMutation(events: events)
//}
