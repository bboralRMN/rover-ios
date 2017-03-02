//
//  FrameworkContextPluginTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class FrameworkContextPluginTests: XCTestCase {
    
    func testCapturesCurrentFrameworks() {
        let identifiers = ["io.rover.Rover"]
        
        let context = FrameworkContextPlugin(identifiers: identifiers).captureContext(Context())
        let frameworks = context["frameworks"] as! Context
        
        XCTAssertEqual(frameworks.count, 1)
        XCTAssertEqual(frameworks["io.rover.Rover"] as! String, "2.0.0")
    }
    
    func testAllowsInvalidIdentifiers() {
        let identifiers = [
            "io.rover.Rover",
            "com.example.Giberish"
        ]
        
        let context = FrameworkContextPlugin(identifiers: identifiers).captureContext(Context())
        let frameworks = context["frameworks"] as! Context
        
        XCTAssertEqual(frameworks.count, 1)
        XCTAssertEqual(frameworks["io.rover.Rover"] as! String, "2.0.0")
    }
}
