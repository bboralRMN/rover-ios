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
        XCTAssertNil(anonymousCustomer.authorizer)
        
        let identifiedCustomer = Customer(customerID: "giberish")
        XCTAssertNotNil(identifiedCustomer.authorizer)
        
        let url = URL(string: "http://example.com")!
        let request = URLRequest(url: url)
        let authorizedRequest = identifiedCustomer.authorizer!.authorize(request)
        let header = authorizedRequest.value(forHTTPHeaderField: "x-rover-customer-id")
        XCTAssertEqual(header, "giberish")
    }
}
