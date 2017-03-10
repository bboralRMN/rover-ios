//
//  EventsPluginTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData

@testable import Rover

class EventsPluginTests: XCTestCase {
    
    func testEventsManagerIsSingleton() {
        let factory = MockEventsFactory()
        let eventsManager = EventsManager(taskFactory: factory)
        let action = MockAction()
        let resolver = MockResolver()
        let nextManager = EventsPlugin.reduce(state: eventsManager, action: action, resolver: resolver)
        XCTAssert(eventsManager === nextManager)
    }
    
    func testNoOpReduce() {
        let factory = MockEventsFactory()
        let eventsManager = EventsManager(taskFactory: factory)
        XCTAssertEqual(eventsManager.contextProviders.count, 0)
        
        let action = MockAction()
        let resolver = MockResolver()
        EventsPlugin.reduce(state: eventsManager, action: action, resolver: resolver)
        XCTAssertEqual(eventsManager.contextProviders.count, 0)
    }
    
    func testAddContextProvider() {
        let factory = MockEventsFactory()
        let eventsManager = EventsManager(taskFactory: factory)
        XCTAssertEqual(eventsManager.contextProviders.count, 0)
        
        let contextProvider = MockContextProvider()
        let action = AddContextProviderAction(contextProvider: contextProvider)
        let resolver = MockResolver()
        EventsPlugin.reduce(state: eventsManager, action: action, resolver: resolver)
        XCTAssertEqual(eventsManager.contextProviders.count, 1)
    }
    
    func testAuthorizerActionUpdatesHTTPFactory() {
        let mockFactory = MockEventsFactory()
        let eventsManager = EventsManager(taskFactory: mockFactory)
        XCTAssertFalse(eventsManager.taskFactory is HTTPFactory)
        
        let authorizer = DeviceIDAuthorizer()
        let action = AddAuthorizerAction(authorizer: authorizer)
        let resolver = MockResolver()
        EventsPlugin.reduce(state: eventsManager, action: action, resolver: resolver)
        XCTAssertTrue(eventsManager.taskFactory is HTTPFactory)
    }
    
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

fileprivate class MockEventsFactory: EventTaskFactory {
    
    var trackEventsWasCalled = false
    
    fileprivate func trackEventsTask(events: [EventInputType], completionHandler: ((TrackEventsResult) -> Void)?) -> HTTPTask {
        
        trackEventsWasCalled = true
        
        return MockTask(block: { 
            let result = TrackEventsResult.success
            completionHandler?(result)
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


fileprivate struct MockAction: Action {
    
}

fileprivate struct MockResolver: Resolver {
    
    func resolve<T : Plugin>(_ pluginType: T.Type, name: String?) -> T.State? {
        switch pluginType {
        case is HTTPPlugin.Type:
            return HTTPFactory() as? T.State
        default:
            return nil
        }
    }
}

fileprivate struct MockContextProvider: ContextProvider {
    
    fileprivate func captureContext(_ context: Context) -> Context {
        return Context()
    }
}
