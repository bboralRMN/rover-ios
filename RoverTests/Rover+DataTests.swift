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
        
        let store = DataStore()
        rover.register(HTTPFactory.self, store: store)
        
        let factory = rover.resolve(HTTPFactory.self)!
        XCTAssertEqual(factory.authorizers.count, 0)
        
        let authorizer = DeviceIDAuthorizer()
        rover.addAuthorizer(authorizer)
        let nextFactory = rover.resolve(HTTPFactory.self)!
        XCTAssertEqual(nextFactory.authorizers.count, 1)
    }
    
    // TODO: Test Sync
}
