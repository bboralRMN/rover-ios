//
//  RoverTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import Foundation

import RoverEvents
import RoverFoundation
import RoverHTTP
import RoverSync
import RoverUser

@testable import Rover

class RoverTests: XCTestCase {

    func testAssemble() {
        Rover.assemble(accountToken: "foo")
        
        XCTAssertNotNil(Rover.shared.resolve(EventsDataService.self))
        XCTAssertNotNil(Rover.shared.resolve(EventsManagerService.self))
        XCTAssertNotNil(Rover.shared.resolve(SyncDataService.self))
        XCTAssertNotNil(Rover.shared.resolve(UserDataService.self))
        XCTAssertNotNil(Rover.shared.resolve(UserService.self))
    }
}
