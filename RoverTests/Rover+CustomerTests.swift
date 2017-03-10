//
//  Rover+CustomerTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class Rover_CustomerTests: XCTestCase {

    func testSetCustomerID() {
        let rover = Rover()
        let storage = MockStorage()
        var customer = Customer(storage: storage)
        rover.register(CustomerPlugin.self, initialState: customer)
        
        customer = rover.resolve(CustomerPlugin.self)!
        XCTAssertNil(customer.customerID)
        
        rover.setCustomerID("giberish")
        customer = rover.resolve(CustomerPlugin.self)!
        XCTAssertEqual(customer.customerID, "giberish")
    }
}

fileprivate struct MockStorage: CustomerIDStorage {
    
    var customerID: String?
    
    init(customerID: String? = nil) {
        self.customerID = customerID
    }
}
