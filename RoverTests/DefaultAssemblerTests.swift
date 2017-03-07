//
//  APITests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-28.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class APITests: XCTestCase {
    
    func testAssemblyConfiguration() {
        let rover = Rover()
        
        let assembler = DefaultAssembler(accountToken: "giberish")
        assembler.assemble(container: rover)
        
        let httpPlugin = rover.resolve(HTTPPlugin.self)!
        XCTAssertEqual(httpPlugin.authorizers.count, 2)
        
        let eventsPlugin = rover.resolve(EventsPlugin.self)!
        XCTAssertEqual(eventsPlugin.contextProviders.count, 8)
    }
    
    func testEventsManagerRetainsQueue() {
        let rover = Rover()
        
        let assembler = DefaultAssembler(accountToken: "giberish")
        assembler.assemble(container: rover)
        
        let eventsPlugin = rover.resolve(EventsPlugin.self)!
        eventsPlugin.trackEvent(name: "Test")
        eventsPlugin.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsPlugin.eventQueue.count, 1)
        
        assembler.assemble(container: rover)
        
        let eventsPlugin2 = rover.resolve(EventsPlugin.self)!
        XCTAssertEqual(eventsPlugin2.eventQueue.count, 1)
    }
}
