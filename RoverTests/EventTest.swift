//
//  EventTest.swift
//  Rover
//
//  Created by Sean Rucker on 2016-11-29.
//  Copyright © 2016 Rover Labs Inc. All rights reserved.
//

import XCTest
@testable import Rover

class EventTest: XCTestCase {
    
    func testDefaultValues() {
        let a = Event(name: "a")
        XCTAssertNil(a.attributes)
        XCTAssertNotNil(a.eventId)
        XCTAssertNotNil(a.timestamp)
        
        let attributes = ["foo": "bar"]
        let b = Event(name: "b", attributes: attributes)
        XCTAssertNotNil(b.attributes)
        XCTAssertNotNil(b.eventId)
        XCTAssertNotNil(b.timestamp)
        
        let uuid = UUID()
        let c = Event(name: "c", eventId: uuid)
        XCTAssertNil(c.attributes)
        XCTAssertEqual(c.eventId, uuid)
        XCTAssertNotNil(c.timestamp)
        
        let date = Date()
        let d = Event(name: "d", timestamp: date)
        XCTAssertNil(d.attributes)
        XCTAssertNotNil(d.eventId)
        XCTAssertEqual(d.timestamp, date)
        
        let e = Event(name: "e", attributes: ["foo": "bar"], eventId: uuid, timestamp: date)
        XCTAssertNotNil(e.attributes)
        XCTAssertEqual(e.eventId, uuid)
        XCTAssertEqual(e.timestamp, date)
    }
}
