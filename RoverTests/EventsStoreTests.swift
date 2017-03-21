//
//  EventsStoreTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData

@testable import Rover

class EventsStoreTests: XCTestCase {
    
    func testRegister() {
        let store = EventsStore()
        XCTAssertNil(store.currentState)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let registeredStore = store.register(resolver: resolver, dispatcher: dispatcher)
        XCTAssertNotNil(registeredStore.currentState)
    }
    
    func testNoOpAction() {
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let store = EventsStore().register(resolver: resolver, dispatcher: dispatcher)
        
        let action = MockAction()
        let nextStore = store.reduce(action: action, resolver: resolver)
        XCTAssert(store.currentState === nextStore.currentState)
    }
    
    func testAddContextProvider() {
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let store = EventsStore().register(resolver: resolver, dispatcher: dispatcher)
        XCTAssertEqual(store.currentState!.contextProviders.count, 0)
        
        let contextProvider = MockContextProvider()
        let action = AddContextProviderAction(contextProvider: contextProvider)
        let nextStore = store.reduce(action: action, resolver: resolver)
        XCTAssert(store.currentState === nextStore.currentState)
        XCTAssertEqual(nextStore.currentState!.contextProviders.count, 1)
    }
    
    func testAuthorizerActionUpdatesHTTPFactory() {
        let store = EventsStore(eventsManager: nil) { resolver, dispatcher in
            let taskFactory = MockEventsFactory()
            let eventsManager = EventsManager(taskFactory: taskFactory)
            return EventsStore(eventsManager: eventsManager)
        }
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let registeredStore = store.register(resolver: resolver, dispatcher: dispatcher)
        XCTAssert(registeredStore.currentState!.taskFactory is MockEventsFactory)
        
        let authHeader = AuthHeader(headerField: "foo", value: "bar")
        let action = AddAuthHeaderAction(authHeader: authHeader)
        let nextStore = registeredStore.reduce(action: action, resolver: resolver)
        XCTAssertTrue(nextStore.currentState!.taskFactory is HTTPFactory)
    }    
}

fileprivate class MockEventsFactory: EventsTaskFactory {
    
    func trackEventsTask(events: [EventInput], completionHandler: ((TrackEventsResult) -> Void)?) -> HTTPTask {
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

fileprivate struct MockAction: Action { }

fileprivate struct MockResolver: Resolver {
    
    func resolve<T : Service>(_ serviceType: T.Type, name: String?) -> T? {
        return HTTPFactory() as? T
    }
}

fileprivate struct MockDispatcher: Dispatcher {
    
    func dispatch(action: Action) { }
}

fileprivate struct MockContextProvider: ContextProvider {
    
    fileprivate func captureContext(_ context: Context) -> Context {
        return Context()
    }
}
