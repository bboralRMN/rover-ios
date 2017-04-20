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
        
        let container = Rover.shared.container
        XCTAssertNotNil(container.resolve(HTTPState.self))
        XCTAssertNotNil(container.resolve(EventsState.self))
        XCTAssertNotNil(container.resolve(SyncState.self))
        XCTAssertNotNil(container.resolve(UserState.self))
    }
}
