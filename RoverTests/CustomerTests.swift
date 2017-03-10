//
//  CustomerTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class CustomerTests: XCTestCase {
    
    func testSettingCustomerIDSavesToStorage() {
        let storage = MockStorage()
        var customer = Customer(storage: storage)
        XCTAssertNil(customer.storage.customerID)
        
        customer.customerID = "giberish"
        XCTAssertEqual(customer.storage.customerID, "giberish")
    }
    
    func testCustomerIDIsRetrievedFromStorage() {
        let storage = MockStorage(customerID: "giberish")
        let customer = Customer(storage: storage)
        XCTAssertEqual(customer.customerID, "giberish")
    }
    
    func testLocalStorage() {
        UserDefaults().removePersistentDomain(forName: "io.rover")
        let userDefaults = UserDefaults(suiteName: "io.rover")
        var customer = Customer(storage: userDefaults)
        XCTAssertNil(customer.customerID)
        
        customer.customerID = "giberish"
        var customer2 = Customer(storage: userDefaults)
        XCTAssertEqual(customer2.customerID, "giberish")
    }
}

fileprivate struct MockStorage: CustomerIDStorage {
    
    var customerID: String?
    
    init(customerID: String? = nil) {
        self.customerID = customerID
    }
}
