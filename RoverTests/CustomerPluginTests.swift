//
//  CustomerPluginTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class CustomerPluginTests: XCTestCase {
    
    func testNoOpReduce() {
        let storage = MockStorage()
        let customer = Customer(storage: storage)
        XCTAssertNil(customer.customerID)
        
        let action = MockAction()
        let resolver = MockResolver()
        let nextCustomer = CustomerPlugin.reduce(state: customer, action: action, resolver: resolver)
        XCTAssertNil(nextCustomer.customerID)
    }
    
    func testSetCustomerID() {
        let storage = MockStorage()
        let customer = Customer(storage: storage)
        XCTAssertNil(customer.customerID)
        
        let action = SetCustomerIDAction(customerID: "giberish")
        let resolver = MockResolver()
        let nextCustomer = CustomerPlugin.reduce(state: customer, action: action, resolver: resolver)
        XCTAssertEqual(nextCustomer.customerID, "giberish")
    }

}

fileprivate class MockStorage: CustomerIDStorage {
    
    var customerID: String?
    
    init(customerID: String? = nil) {
        self.customerID = customerID
    }
}


fileprivate struct MockAction: Action { }

fileprivate struct MockResolver: Resolver {
    
    func resolve<T : Plugin>(_ pluginType: T.Type, name: String?) -> T.State? {
        return nil
    }
}
