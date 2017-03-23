//
//  EventsServiceFactoryTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData

@testable import Rover

class EventsServiceFactoryTests: XCTestCase {
    
    func testRegister() {
        let url = URL(string: "http://example.com")!
        let httpService = HTTPService(baseURL: url)
        let resolver = MockResolver(httpService: httpService)
        let dispatcher = MockDispatcher()
        let factory = EventsServiceFactory()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)
        
        XCTAssertEqual(initialState.uploadService as! HTTPService, httpService)
    }
    
    func testConfigureEventsService() {
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let contextProvider = MockContextProvider()
        
        let factory = EventsServiceFactory(contextProviders: [contextProvider],
                                           flushAt: 3,
                                           flushInterval: 3.3,
                                           maxBatchSize: 33,
                                           maxQueueSize: 333)
        
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)
        
        XCTAssertEqual(initialState.contextProviders.count, 1)
        XCTAssertEqual(initialState.flushAt, 3)
        XCTAssertEqual(initialState.flushInterval, 3.3)
        XCTAssertEqual(initialState.eventQueue.maxBatchSize, 33)
        XCTAssertEqual(initialState.eventQueue.maxQueueSize, 333)
    }
    
    func testUnmetDependency() {
        let resolver = MockResolver(httpService: nil)
        let dispatcher = MockDispatcher()
        
        do {
            let _ = try EventsServiceFactory().register(resolver: resolver, dispatcher: dispatcher)
            XCTFail()
        } catch {
            switch error {
            case ServiceRegistrationError.unmetDependency:
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testNoOpAction() {
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let factory = EventsServiceFactory()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)
        
        let action = MockAction()
        let nextState = factory.reduce(state: initialState, action: action, resolver: resolver)
        
        XCTAssert(nextState === initialState)
    }
    
    func testAddContextProvider() {
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let factory = EventsServiceFactory()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)

        XCTAssertEqual(initialState.contextProviders.count, 8)
        
        let contextProvider = MockContextProvider()
        let action = AddContextProviderAction(contextProvider: contextProvider)
        let nextState = factory.reduce(state: initialState, action: action, resolver: resolver)
        
        XCTAssert(nextState === initialState)
        XCTAssertEqual(nextState.contextProviders.count, 9)
    }
    
    func testAuthorizerActionUpdatesHTTPService() {
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let factory = EventsServiceFactory()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)
        
        let firstCount = (initialState.uploadService as! HTTPService).authHeaders.count
        XCTAssertEqual(firstCount, 0)
        
        let authHeader = AuthHeader(headerField: "foo", value: "bar")
        let action = AddAuthHeaderAction(authHeader: authHeader)
        
        let customHTTPService = HTTPService(authHeaders: [authHeader])
        let customResolver = MockResolver(httpService: customHTTPService)
        let nextState = factory.reduce(state: initialState, action: action, resolver: customResolver)
        
        let secondCount = (nextState.uploadService as! HTTPService).authHeaders.count
        XCTAssertEqual(secondCount, 1)
    }    
}

// MARK: MockAction

fileprivate struct MockAction: Action { }

// MARK: MockResolver

fileprivate struct MockResolver: Resolver {
    
    let serviceMap = ServiceMap()
    
    let httpService: HTTPService?
    
    init(httpService: HTTPService? = HTTPService()) {
        self.httpService = httpService
    }
    
    func resolve<T : Service>(_ serviceType: T.Type, name: String?) -> T? {
        return httpService as? T
    }
}

// MARK: MockDispatcher

fileprivate struct MockDispatcher: Dispatcher {
    
    func dispatch(action: Action) { }
}

// MARK: MockContextProvider

fileprivate struct MockContextProvider: ContextProvider {
    
    fileprivate func captureContext(_ context: Context) -> Context {
        return Context()
    }
}
