//
//  Rover+DataTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData

@testable import Rover

class Rover_DataTests: XCTestCase {

    func testAddAuthorizer() {
        let rover = Rover()
        
        let store = DataStore(accountToken: "giberish")
        rover.register(HTTPService.self, store: store)
        
        let factory = rover.resolve(HTTPService.self)!
        XCTAssertEqual(factory.authHeaders.count, 2)
        
        let authHeader = AuthHeader(headerField: "foo", value: "bar")
        rover.addAuthHeader(authHeader)
        let nextFactory = rover.resolve(HTTPService.self)!
        XCTAssertEqual(nextFactory.authHeaders.count, 3)
    }
    
    // TODO: Test Sync
}
