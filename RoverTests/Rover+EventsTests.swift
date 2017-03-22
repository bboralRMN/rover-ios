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
        
        let httpFactory = HTTPServiceFactory(accountToken: "giberish")
        try! rover.register(HTTPService.self, factory: httpFactory)
        
        let eventsFactory = EventsManagerFactory()
        try! rover.register(EventsManager.self, factory: eventsFactory)
        
        let eventsManager = rover.resolve(EventsManager.self)!
        XCTAssertEqual(eventsManager.contextProviders.count, 8)
        
        let contextProvider = MockContextProvider()
        rover.addContextProvider(contextProvider)
        XCTAssertEqual(eventsManager.contextProviders.count, 9)
    }
    
    func testRoverTrackEvent() {
        let rover = Rover()
        
        let httpFactory = HTTPServiceFactory(accountToken: "giberish")
        try! rover.register(HTTPService.self, factory: httpFactory)
        
        let eventsFactory = EventsManagerFactory()
        try! rover.register(EventsManager.self, factory: eventsFactory)
        
        let eventsManager = rover.resolve(EventsManager.self)!
        XCTAssertEqual(eventsManager.eventQueue.count, 0)
        
        rover.trackEvent(name: "Test")
        
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 1)
    }
    
    func testRoverTrackEventCapturesAuthHeaders() {
        let rover = Rover()
        
        let httpFactory = HTTPServiceFactory(accountToken: "giberish")
        try! rover.register(HTTPService.self, factory: httpFactory)
        
        let eventsFactory = EventsManagerFactory()
        try! rover.register(EventsManager.self, factory: eventsFactory)
        
        rover.trackEvent(name: "Test")
        
        let eventsManager = rover.resolve(EventsManager.self)!
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        
        let event = eventsManager.eventQueue.events[0]
        XCTAssertEqual(event.authHeaders!.count, 2)
        
        let authHeader = AuthHeader(headerField: "foo", value: "bar")
        rover.addAuthHeader(authHeader)
        rover.trackEvent(name: "Test")
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        
        let nextEvent = eventsManager.eventQueue.events[1]
        XCTAssertEqual(nextEvent.authHeaders!.count, 3)
        XCTAssertEqual(nextEvent.authHeaders!.last!.headerField, "foo")
        XCTAssertEqual(nextEvent.authHeaders!.last!.value, "bar")
    }
    
    func testRoverFlushEvents() {
        let rover = Rover()
        
        let session = MockSession()
        let httpFactory = HTTPServiceFactory(accountToken: "giberish", session: session)
        try! rover.register(HTTPService.self, factory: httpFactory)
        
        let eventsFactory = EventsManagerFactory()
        try! rover.register(EventsManager.self, factory: eventsFactory)

        let eventsManager = rover.resolve(EventsManager.self)!
        XCTAssertEqual(eventsManager.eventQueue.count, 0)
        
        rover.trackEvent(name: "Test")
        
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 1)
        
        rover.flushEvents()
        
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 0)
    }
}

// MARK: MockContextProvider

fileprivate struct MockContextProvider: ContextProvider {
    
    fileprivate func captureContext(_ context: Context) -> Context {
        return Context()
    }
}

// MARK: MockSession

fileprivate class MockSession: HTTPSession {
    
    func uploadTask(with request: URLRequest,
                    from bodyData: Data?,
                    completionHandler: @escaping UploadTaskHandler) -> HTTPTask {
        
        return MockTask() {
            let url = URL(string: "http://example.com")!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            completionHandler(nil, response, nil)
        }
    }
}

// MARK: MockTask

fileprivate class MockTask: HTTPTask {
    
    var block: (() -> Void)?
    
    init(block: (() -> Void)? = nil) {
        self.block = block
    }
    
    func cancel() { }
    
    func resume() {
        block?()
    }
}
