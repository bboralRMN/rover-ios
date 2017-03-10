//
//  Rover+HTTPTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData

@testable import Rover

class Rover_HTTPTests: XCTestCase {

    func testAddAuthorizer() {
        let rover = Rover()
        
        var factory = HTTPFactory()
        rover.register(HTTPPlugin.self, initialState: factory)
        factory = rover.resolve(HTTPPlugin.self)!
        XCTAssertEqual(factory.authorizers.count, 0)
        
        let authorizer = DeviceIDAuthorizer()
        rover.addAuthorizer(authorizer)
        factory = rover.resolve(HTTPPlugin.self)!
        XCTAssertEqual(factory.authorizers.count, 1)
    }
}
