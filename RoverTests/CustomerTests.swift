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
    
    func testAuthorizer() {
        let anonymousCustomer = Customer()
        XCTAssertNil(anonymousCustomer.authHeader)
        
        let identifiedCustomer = Customer(customerID: "giberish")
        let authHeader = identifiedCustomer.authHeader!
        XCTAssertEqual(authHeader.headerField, "x-rover-customer-id")
        XCTAssertEqual(authHeader.value, "giberish")
    }
}
