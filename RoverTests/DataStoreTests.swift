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
        let store = DataStore()
        XCTAssertNil(store.currentState)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let registeredStore = store.register(resolver: resolver, dispatcher: dispatcher)
        XCTAssertNotNil(registeredStore.currentState)
    }
    
    func testNoOpAction() {
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let store = DataStore().register(resolver: resolver, dispatcher: dispatcher)
        XCTAssertEqual(store.currentState!.authorizers.count, 0)
        
        let action = MockAction()
        let nextStore = store.reduce(action: action, resolver: resolver)
        XCTAssertEqual(nextStore.currentState!.authorizers.count, 0)
    }
    
    func testAddAuthorizer() {
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let store = DataStore().register(resolver: resolver, dispatcher: dispatcher)
        XCTAssertEqual(store.currentState!.authorizers.count, 0)
        
        let authorizer = MockAuthorizer()
        let action = AddAuthorizerAction(authorizer: authorizer)
        let nextStore = store.reduce(action: action, resolver: resolver)
        XCTAssertEqual(nextStore.currentState!.authorizers.count, 1)
    }
}

fileprivate struct MockAuthorizer: Authorizer {
    
    fileprivate func authorize(_ request: URLRequest) -> URLRequest {
        return request
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
