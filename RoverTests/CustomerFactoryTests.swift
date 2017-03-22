//
//  CustomerFactoryTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData

@testable import Rover

class CustomerFactoryTests: XCTestCase {
    
    func testRegister() {
        let localStorage = MockStorage()
        let factory = CustomerFactory(localStorage: localStorage)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = factory.register(resolver: resolver, dispatcher: dispatcher)
        
        XCTAssertNil(initialState.customerID)
    }
    
    func testRegisterWithStoredCustomerID() {
        let localStorage = MockStorage(customerID: "giberish")
        let factory = CustomerFactory(localStorage: localStorage)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = factory.register(resolver: resolver, dispatcher: dispatcher)
        
        XCTAssertEqual(initialState.customerID, "giberish")
    }
    
    func testNoOpAction() {
        let localStorage = MockStorage()
        let factory = CustomerFactory(localStorage: localStorage)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = factory.register(resolver: resolver, dispatcher: dispatcher)
        
        let action = MockAction()
        let nextState = factory.reduce(state: initialState, action: action, resolver: resolver)
        
        XCTAssert(factory.areEqual(a: initialState, b: nextState))
    }
    
    func testIdentifyCustomer() {
        let localStorage = MockStorage()
        let factory = CustomerFactory(localStorage: localStorage)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = factory.register(resolver: resolver, dispatcher: dispatcher)
        
        XCTAssertNil(initialState.customerID)
        
        let action = IdentifyCustomerAction(customerID: "giberish")
        let nextState = factory.reduce(state: initialState, action: action, resolver: resolver)
        
        XCTAssertEqual(nextState.customerID, "giberish")
        XCTAssertEqual(localStorage.customerID, "giberish")
    }
    
    func testSyncResult() {
        let localStorage = MockStorage()
        let factory = CustomerFactory(localStorage: localStorage)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = factory.register(resolver: resolver, dispatcher: dispatcher)

        XCTAssertNil(initialState.customerID)
        XCTAssertNil(initialState.firstName)
        XCTAssertNil(initialState.lastName)
        XCTAssertNil(initialState.email)
        XCTAssertNil(initialState.gender)
        XCTAssertNil(initialState.age)
        XCTAssertNil(initialState.phoneNumber)
        XCTAssertNil(initialState.tags)
        XCTAssertNil(initialState.traits)
        
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
        let nextState = factory.reduce(state: initialState, action: action, resolver: resolver)
        
        XCTAssertEqual(nextState.customerID, "80000516109")
        XCTAssertEqual(nextState.firstName, "Marie")
        XCTAssertEqual(nextState.lastName, "Avgeropoulos")
        XCTAssertEqual(nextState.email, "marie.avgeropoulos@example.com")
        XCTAssertEqual(nextState.gender, .female)
        XCTAssertEqual(nextState.age, 30)
        XCTAssertEqual(nextState.phoneNumber, "555-555-5555")
        XCTAssertEqual(nextState.tags!, ["actress", "model", "musician"])
        XCTAssertEqual(nextState.traits!["height"] as! Double, 1.65)
    }
    
    func testMismatchedCustomerIDSyncResult() {
        let localStorage = MockStorage(customerID: "foo")
        let factory = CustomerFactory(localStorage: localStorage)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = factory.register(resolver: resolver, dispatcher: dispatcher)

        XCTAssertEqual(initialState.customerID, "foo")
        XCTAssertNil(initialState.firstName)
        
        let customer = SyncResult.Customer(customerID: "bar", firstName: "Marie")
        let syncResult = SyncResult.success(customer: customer)
        let action = SyncCompleteAction(syncResult: syncResult)
        let nextState = factory.reduce(state: initialState, action: action, resolver: resolver)
        
        XCTAssertEqual(nextState.customerID, "foo")
        XCTAssertNil(nextState.firstName)
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
