//
//  UserServiceTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class UserServiceTests: XCTestCase {
    
    func testAuthorizer() {
        let anonymousUser = UserService()
        XCTAssertNil(anonymousUser.authHeader)
        
        let identifiedUser = UserService(userID: "giberish")
        let authHeader = identifiedUser.authHeader!
        XCTAssertEqual(authHeader.headerField, "x-rover-user-id")
        XCTAssertEqual(authHeader.value, "giberish")
    }
}
