//
//  EventQueueTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class EventQueueTests: XCTestCase {
    
    func testRoverEventQueue() {
        let generatedEvents = (1...9).map { Event(name: "\($0)") } // generatedEvents: [1][2][3][4][5][6][7][8][9]
        
        var eventQueue = EventQueue(maxQueueSize: 5, maxBatchSize: 3) // eventQueue: <empty>
        XCTAssertEqual(eventQueue.count, 0)
        
        var batch = eventQueue.nextBatch(minSize: 2) // batch: <empty>
        XCTAssertEqual(batch.count, 0)
        
        generatedEvents[0..<5].forEach { eventQueue.add(event: $0) } // eventQueue: [1][2][3][4][5]
        XCTAssertEqual(eventQueue.count, 5)
        XCTAssertEqual(eventQueue.events.first?.name, "1")
        XCTAssertEqual(eventQueue.events.last?.name, "5")
        
        batch = eventQueue.nextBatch(minSize: 2) // batch: [1][2][3]
        XCTAssertEqual(batch.count, 3)
        XCTAssertEqual(batch.first?.name, "1")
        XCTAssertEqual(batch.last?.name, "3")
        
        eventQueue.remove(batch: batch) // eventQueue: [4][5]
        XCTAssertEqual(eventQueue.count, 2)
        XCTAssertEqual(eventQueue.events.first?.name, "4")
        XCTAssertEqual(eventQueue.events.last?.name, "5")
        
        generatedEvents[5..<9].forEach { eventQueue.add(event: $0) } // eventQueue: [5][6][7][8][9]
        XCTAssertEqual(eventQueue.count, 5)
        XCTAssertEqual(eventQueue.events.first?.name, "5")
        XCTAssertEqual(eventQueue.events.last?.name, "9")
        
        batch = eventQueue.nextBatch(minSize: 10) // batch: <empty>
        XCTAssertEqual(batch.count, 0)
        
        batch = eventQueue.nextBatch(minSize: 2) // batch: [5][6][7]
        XCTAssertEqual(batch.count, 3)
        XCTAssertEqual(batch.first?.name, "5")
        XCTAssertEqual(batch.last?.name, "7")
        
        eventQueue.remove(batch: batch) // eventQueue: [8][9]
        XCTAssertEqual(eventQueue.count, 2)
        XCTAssertEqual(eventQueue.events.first?.name, "8")
        XCTAssertEqual(eventQueue.events.last?.name, "9")
        
        batch = eventQueue.nextBatch(minSize: 2) // batch: [8][9]
        XCTAssertEqual(batch.count, 2)
        XCTAssertEqual(batch.first?.name, "8")
        XCTAssertEqual(batch.last?.name, "9")
        
        eventQueue.remove(batch: batch) // eventQueue: <empty>
        XCTAssertEqual(eventQueue.count, 0)
    }
}
