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
        
        let uploadService = MockUploadService()
        let eventsManager = EventsManager(uploadService: uploadService)
        let store = EventsStore(eventsManager: nil) { resolver, dispatcher in
            return EventsStore(eventsManager: eventsManager)
        }
        
        rover.register(EventsManager.self, store: store)
        XCTAssertEqual(eventsManager.contextProviders.count, 0)
        
        let contextProvider = MockContextProvider()
        rover.addContextProvider(contextProvider)
        XCTAssertEqual(eventsManager.contextProviders.count, 1)
    }
    
    func testRoverTrackEvent() {
        let rover = Rover()
        
        let uploadService = MockUploadService()
        let eventsManager = EventsManager(uploadService: uploadService, flushAt: 1)
        let store = EventsStore(eventsManager: nil) { resolver, dispatcher in
            return EventsStore(eventsManager: eventsManager)
        }

        rover.register(EventsManager.self, store: store)
        XCTAssertFalse(uploadService.trackEventsWasCalled)
        
        rover.trackEvent(name: "Test")
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertTrue(uploadService.trackEventsWasCalled)
    }
    
    func testRoverFlushEvents() {
        let rover = Rover()
        
        let uploadService = MockUploadService()
        let eventsManager = EventsManager(uploadService: uploadService)
        let store = EventsStore(eventsManager: nil) { resolver, dispatcher in
            return EventsStore(eventsManager: eventsManager)
        }
        
        rover.register(EventsManager.self, store: store)
        XCTAssertEqual(eventsManager.eventQueue.count, 0)
        
        rover.trackEvent(name: "Test")
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 1)
        
        rover.flushEvents()
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 0)
        XCTAssertTrue(uploadService.trackEventsWasCalled)
    }
}

fileprivate class MockUploadService: TrackEventsService {
    
    var trackEventsWasCalled = false
    
    func trackEventsTask(operation: TrackEventsMutation,
                         authHeaders: [AuthHeader]?,
                         completionHandler: ((TrackEventsResult) -> Void)?) -> HTTPTask {
        
        trackEventsWasCalled = true
        return MockTask(block: {
            completionHandler?(TrackEventsResult.success)
        })
    }
}

fileprivate struct MockTask: HTTPTask {
    
    var block: (() -> Void)?
    
    init(block: (() -> Void)? = nil) {
        self.block = block
    }
    
    func cancel() { }
    
    func resume() {
        block?()
    }
}

fileprivate struct MockContextProvider: ContextProvider {
    
    fileprivate func captureContext(_ context: Context) -> Context {
        return Context()
    }
}
