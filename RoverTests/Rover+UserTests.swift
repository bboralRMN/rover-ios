//
//  Rover+UserTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData

@testable import Rover

class Rover_UserTests: XCTestCase {

    func testSetUserIDUpatesUser() {
        let rover = Rover()
        
        let httpFactory = HTTPServiceFactory(accountToken: "giberish")
        try! rover.register(HTTPService.self, factory: httpFactory)
        
        let localStorage = MockStorage()
        let factory = UserServiceFactory(localStorage: localStorage)
        
        try! rover.register(UserService.self, factory: factory)
        
        let initialState = rover.resolve(UserService.self)!
        XCTAssertNil(initialState.userID)
        
        rover.setUserID("giberish")
        
        let nextState = rover.resolve(UserService.self)!
        XCTAssertEqual(nextState.userID, "giberish")
    }
    
    func testSetUserIDAddsAuthHeader() {
        let rover = Rover()
        
        let httpFactory = HTTPServiceFactory(accountToken: "giberish")
        try! rover.register(HTTPService.self, factory: httpFactory)
        
        let localStorage = MockStorage()
        let userFactory = UserServiceFactory(localStorage: localStorage)
        try! rover.register(UserService.self, factory: userFactory)
        
        let initialState = rover.resolve(HTTPService.self)!
        XCTAssertEqual(initialState.authHeaders.count, 2)
        
        rover.setUserID("giberish")
        
        let nextState = rover.resolve(HTTPService.self)!
        XCTAssertEqual(nextState.authHeaders.count, 3)
    }
    
    func testUpdateUser() {
        let rover = Rover()
        
        let httpFactory = HTTPServiceFactory(accountToken: "giberish")
        try! rover.register(HTTPService.self, factory: httpFactory)
        
        let eventsFactory = EventsServiceFactory()
        try! rover.register(EventsService.self, factory: eventsFactory)
        
        let update = UserUpdate.setFirstName(value: "Marie")
        rover.updateUser([update])
        
        let eventsService = rover.resolve(EventsService.self)!
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        
        let event = eventsService.eventQueue.events[0]
        XCTAssertEqual(event.name, "User Update")
        
        let updates = event.attributes!["updates"] as! [[String: Any]]
        XCTAssertEqual(updates[0]["action"] as! String, "set")
        XCTAssertEqual(updates[0]["key"] as! String, "firstName")
        XCTAssertEqual(updates[0]["value"] as! String, "Marie")
    }
    
    func testGetUser() {
        let rover = Rover()
        
        let httpFactory = HTTPServiceFactory(accountToken: "giberish")
        try! rover.register(HTTPService.self, factory: httpFactory)
        
        let localStorage = MockStorage(userID: "giberish")
        let factory = UserServiceFactory(localStorage: localStorage)
        try! rover.register(UserService.self, factory: factory)
        
        let user = rover.currentUser()!
        XCTAssertEqual(user.userID, "giberish")
    }
}

fileprivate class MockStorage: LocalStorage {
    
    var userID: String?
    
    init(userID: String? = nil) {
        self.userID = userID
    }
    
    func string(forKey defaultName: String) -> String? {
        return userID
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        userID = value as? String
    }
}

fileprivate class MockUploadService: TrackEventsService {
    
    var firstEvent: TrackEventsMutation.Event?
    
    fileprivate func trackEventsTask(operation: TrackEventsMutation,
                                     authHeaders: [AuthHeader]?,
                                     completionHandler: ((TrackEventsResult) -> Void)?) -> HTTPTask {

        firstEvent = operation.events.first
        
        return MockTask {
            completionHandler?(TrackEventsResult.success)
        }
    }
}

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
