//
//  CustomerStoreTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData

@testable import Rover

class CustomerStoreTests: XCTestCase {
    
    func testRegister() {
        let store = CustomerStore()
        XCTAssertNil(store.currentState)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let registeredStore = store.register(resolver: resolver, dispatcher: dispatcher)
        XCTAssertNotNil(registeredStore.currentState)
    }
    
    func testRegisterWithStoredCustomerID() {
        let localStorage = MockStorage(customerID: "giberish")
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let store = CustomerStore(localStorage: localStorage).register(resolver: resolver, dispatcher: dispatcher)
        XCTAssertEqual(store.currentState!.customerID, "giberish")
        
    }
    
    func testNoOpAction() {
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let store = CustomerStore().register(resolver: resolver, dispatcher: dispatcher)
        
        let action = MockAction()
        let nextStore = store.reduce(action: action, resolver: resolver)
        XCTAssertEqual(store.currentState!, nextStore.currentState!)
    }
    
    func testIdentifyCustomer() {
        let localStorage = MockStorage()
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let store = CustomerStore(localStorage: localStorage).register(resolver: resolver, dispatcher: dispatcher)
        XCTAssertNil(store.currentState!.customerID)
        
        let action = IdentifyCustomerAction(customerID: "giberish")
        let nextStore = store.reduce(action: action, resolver: resolver)
        XCTAssertEqual(nextStore.currentState!.customerID, "giberish")
        XCTAssertEqual(localStorage.customerID, "giberish")
    }
}

fileprivate class MockStorage: LocalStorage {
    
    var customerID: String?
    
    init(customerID: String? = nil) {
        self.customerID = customerID
    }
    
    func string(forKey defaultName: String) -> String? {
        return customerID
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        customerID = value as? String
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
