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
        
        let httpFactory = rover.resolve(HTTPPlugin.self)!
        XCTAssertEqual(httpFactory.authorizers.count, 2)
        
        let eventsManager = rover.resolve(EventsPlugin.self)!
        XCTAssertEqual(eventsManager.contextProviders.count, 8)
    }
    
    func testEventsManagerRetainsQueue() {
        let rover = Rover()
        
        let assembler = DefaultAssembler(accountToken: "giberish")
        assembler.assemble(container: rover)
        
        let eventsManager = rover.resolve(EventsPlugin.self)!
        eventsManager.trackEvent(name: "Test")
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 1)
        
        assembler.assemble(container: rover)
        
        let eventsManager2 = rover.resolve(EventsPlugin.self)!
        XCTAssertEqual(eventsManager2.eventQueue.count, 1)
    }
}
