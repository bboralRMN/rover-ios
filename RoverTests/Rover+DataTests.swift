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

    func testAddAuthHeader() {
        let rover = Rover()
        
        let httpFactory = HTTPServiceFactory(accountToken: "giberish")
        try! rover.register(HTTPService.self, factory: httpFactory)
        
        let initialState = rover.resolve(HTTPService.self)!
        XCTAssertEqual(initialState.authHeaders.count, 2)
        
        let authHeader = AuthHeader(headerField: "foo", value: "bar")
        rover.addAuthHeader(authHeader)
        
        let nextState = rover.resolve(HTTPService.self)!
        XCTAssertEqual(nextState.authHeaders.count, 3)
    }
    
    // TODO: Test Sync
}
