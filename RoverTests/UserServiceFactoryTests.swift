//
//  UserServiceFactoryTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData

@testable import Rover

class UserServiceFactoryTests: XCTestCase {
    
    func testRegister() {
        let localStorage = MockStorage()
        let factory = UserServiceFactory(localStorage: localStorage)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)
        
        XCTAssertNil(initialState.userID)
    }
    
    func testRegisterWithStoredUserID() {
        let localStorage = MockStorage(userID: "giberish")
        let factory = UserServiceFactory(localStorage: localStorage)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)
        
        XCTAssertEqual(initialState.userID, "giberish")
    }
    
    func testNoOpAction() {
        let localStorage = MockStorage()
        let factory = UserServiceFactory(localStorage: localStorage)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)
        
        let action = MockAction()
        let nextState = factory.reduce(state: initialState, action: action, resolver: resolver)
        
        XCTAssert(factory.areEqual(a: initialState, b: nextState))
    }
    
    func testIdentifyUser() {
        let localStorage = MockStorage()
        let factory = UserServiceFactory(localStorage: localStorage)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)
        
        XCTAssertNil(initialState.userID)
        
        let action = IdentifyUserAction(userID: "giberish")
        let nextState = factory.reduce(state: initialState, action: action, resolver: resolver)
        
        XCTAssertEqual(nextState.userID, "giberish")
        XCTAssertEqual(localStorage.userID, "giberish")
    }
    
    func testSyncResult() {
        let localStorage = MockStorage()
        let factory = UserServiceFactory(localStorage: localStorage)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)

        XCTAssertNil(initialState.userID)
        XCTAssertNil(initialState.firstName)
        XCTAssertNil(initialState.lastName)
        XCTAssertNil(initialState.email)
        XCTAssertNil(initialState.gender)
        XCTAssertNil(initialState.age)
        XCTAssertNil(initialState.phoneNumber)
        XCTAssertNil(initialState.tags)
        XCTAssertNil(initialState.traits)
        
        let user = SyncResult.User(userID: "80000516109",
                                           firstName: "Marie",
                                           lastName: "Avgeropoulos",
                                           email: "marie.avgeropoulos@example.com",
                                           gender: .female,
                                           age: 30,
                                           phoneNumber: "555-555-5555",
                                           tags: ["actress", "model", "musician"],
                                           traits: ["height": 1.65])
        
        let syncResult = SyncResult.success(user: user)
        let action = SyncCompleteAction(syncResult: syncResult)
        let nextState = factory.reduce(state: initialState, action: action, resolver: resolver)
        
        XCTAssertEqual(nextState.userID, "80000516109")
        XCTAssertEqual(nextState.firstName, "Marie")
        XCTAssertEqual(nextState.lastName, "Avgeropoulos")
        XCTAssertEqual(nextState.email, "marie.avgeropoulos@example.com")
        XCTAssertEqual(nextState.gender, .female)
        XCTAssertEqual(nextState.age, 30)
        XCTAssertEqual(nextState.phoneNumber, "555-555-5555")
        XCTAssertEqual(nextState.tags!, ["actress", "model", "musician"])
        XCTAssertEqual(nextState.traits!["height"] as! Double, 1.65)
    }
    
    func testMismatchedUserIDSyncResult() {
        let localStorage = MockStorage(userID: "foo")
        let factory = UserServiceFactory(localStorage: localStorage)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)

        XCTAssertEqual(initialState.userID, "foo")
        XCTAssertNil(initialState.firstName)
        
        let user = SyncResult.User(userID: "bar", firstName: "Marie")
        let syncResult = SyncResult.success(user: user)
        let action = SyncCompleteAction(syncResult: syncResult)
        let nextState = factory.reduce(state: initialState, action: action, resolver: resolver)
        
        XCTAssertEqual(nextState.userID, "foo")
        XCTAssertNil(nextState.firstName)
    }
}

// MARK: MockStorage

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
