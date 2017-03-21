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
        let _ = store.reduce(action: action, resolver: resolver)
//        XCTAssertEqual(store.currentState!, nextStore.currentState!)
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
    
    func testSyncResult() {
        let localStorage = MockStorage()
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let store = CustomerStore(localStorage: localStorage).register(resolver: resolver, dispatcher: dispatcher)
        
        let customer = SyncResult.Customer(customerID: "80000516109",
                                           firstName: "Marie",
                                           lastName: "Avgeropoulos",
                                           email: "marie.avgeropoulos@example.com",
                                           gender: .female,
                                           age: 30,
                                           phoneNumber: "555-555-5555",
                                           tags: ["actress", "model", "musician"],
                                           traits: ["height": 1.65])
        
        let syncResult = SyncResult.success(customer: customer)
        let action = SyncCompleteAction(syncResult: syncResult)
        let nextStore = store.reduce(action: action, resolver: resolver)
        let state = nextStore.currentState!
        XCTAssertEqual(state.customerID, "80000516109")
        XCTAssertEqual(state.firstName, "Marie")
        XCTAssertEqual(state.lastName, "Avgeropoulos")
        XCTAssertEqual(state.email, "marie.avgeropoulos@example.com")
        XCTAssertEqual(state.gender, .female)
        XCTAssertEqual(state.age, 30)
        XCTAssertEqual(state.phoneNumber, "555-555-5555")
        XCTAssertEqual(state.tags!, ["actress", "model", "musician"])
        XCTAssertEqual(state.traits!["height"] as! Double, 1.65)
    }
    
    func testMismatchedCustomerIDSyncResult() {
        let localStorage = MockStorage(customerID: "foo")
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let store = CustomerStore(localStorage: localStorage).register(resolver: resolver, dispatcher: dispatcher)
        XCTAssertEqual(store.currentState!.customerID, "foo")
        XCTAssertNil(store.currentState!.firstName)
        
        let customer = SyncResult.Customer(customerID: "bar", firstName: "Marie")
        let syncResult = SyncResult.success(customer: customer)
        let action = SyncCompleteAction(syncResult: syncResult)
        let nextStore = store.reduce(action: action, resolver: resolver)
        XCTAssertEqual(nextStore.currentState!.customerID, "foo")
        XCTAssertNil(nextStore.currentState!.firstName)
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

fileprivate struct MockAction: Action { }

fileprivate struct MockResolver: Resolver {
    
    func resolve<T : Service>(_ serviceType: T.Type, name: String?) -> T? {
        return nil
    }
}

fileprivate struct MockDispatcher: Dispatcher {
    
    func dispatch(action: Action) { }
}
