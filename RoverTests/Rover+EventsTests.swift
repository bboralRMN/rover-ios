//
//  Rover+EventsTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData

@testable import Rover

class Rover_EventsTests: XCTestCase {
    
    func testRoverAddContextProvider() {
        let rover = Rover()
        
        let httpFactory = HTTPFactory()
        rover.register(HTTPPlugin.self, initialState: httpFactory)
        
        let eventsManager = EventsManager(taskFactory: httpFactory)
        rover.register(EventsPlugin.self, initialState: eventsManager)
        
        XCTAssertEqual(eventsManager.contextProviders.count, 0)
        
        let contextProvider = MockContextProvider()
        rover.addContextProvider(contextProvider)
        XCTAssertEqual(eventsManager.contextProviders.count, 1)
    }
    
    func testRoverTrackEvent() {
        let rover = Rover()
        let httpFactory = HTTPFactory()
        rover.register(HTTPPlugin.self, initialState: httpFactory)
        
        let eventsManager = EventsManager(taskFactory: httpFactory)
        rover.register(EventsPlugin.self, initialState: eventsManager)
        XCTAssertEqual(eventsManager.eventQueue.count, 0)
        
        rover.trackEvent(name: "Test")
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 1)
    }
}

fileprivate struct MockContextProvider: ContextProvider {
    
    fileprivate func captureContext(_ context: Context) -> Context {
        return Context()
    }
}
