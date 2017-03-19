//
//  CustomerIDAuthorizerTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class CustomerIDAuthorizerTests: XCTestCase {
    
    func testAuthorize() {
        let authorizer = CustomerIDAuthorizer(customerID: "giberish")
        let url = URL(string: "http://example.com")!
        let request = URLRequest(url: url)
        let authorizedRequest = authorizer.authorize(request)
        let header = authorizedRequest.value(forHTTPHeaderField: "x-rover-customer-id")
        XCTAssertEqual(header, "giberish")
    }
}
