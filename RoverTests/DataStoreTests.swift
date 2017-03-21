//
//  DataStoreTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

import RoverData

class DataStoreTests: XCTestCase {
    
    func testRegister() {
        let store = DataStore(accountToken: "giberish")
        XCTAssertNil(store.currentState)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let registeredStore = store.register(resolver: resolver, dispatcher: dispatcher)
        XCTAssertNotNil(registeredStore.currentState)
    }
    
    func testNoOpAction() {
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let store = DataStore(accountToken: "giberish").register(resolver: resolver, dispatcher: dispatcher)
        
        let action = MockAction()
        let nextStore = store.reduce(action: action, resolver: resolver)
        XCTAssertEqual(store.currentState, nextStore.currentState)
    }
    
    func testAddAuthorizer() {
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let store = DataStore(accountToken: "giberish").register(resolver: resolver, dispatcher: dispatcher)
        XCTAssertEqual(store.currentState!.authHeaders.count, 2)
        
        let authHeader = AuthHeader(headerField: "foo", value: "bar")
        let action = AddAuthHeaderAction(authHeader: authHeader)
        let nextStore = store.reduce(action: action, resolver: resolver)
        XCTAssertEqual(nextStore.currentState!.authHeaders.count, 3)
    }
}

fileprivate struct MockAction: Action { }

fileprivate struct MockResolver: Resolver {
    
    func resolve<T : Service>(_ serviceType: T.Type, name: String?) -> T? {
        return nil
    }
}

fileprivate struct MockDispatcher: Dispatcher {
    
    func dispatch(action: Action) { }
}
