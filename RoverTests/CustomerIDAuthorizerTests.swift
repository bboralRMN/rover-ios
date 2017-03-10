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
        let result = authorizer.authorize(request)
        XCTAssertEqual(result.allHTTPHeaderFields!["x-rover-customer-id"], "giberish")
    }
}
