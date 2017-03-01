//
//  APITests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-28.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import Rover

class APITests: XCTestCase {
    
    func testCanConfigureRover() {
        let configuration = RoverConfiguration(accountToken: "giberish")
        Rover.configure(configuration)
    }
}
