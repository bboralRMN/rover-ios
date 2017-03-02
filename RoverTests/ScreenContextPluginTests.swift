//
//  ScreenContextPluginTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class ScreenContextPluginTests: XCTestCase {
    
    func testCapture() {
        let size = CGSize(width: 640, height: 480)
        let context = ScreenContextPlugin(screenSize: size).captureContext(Context())
        
        XCTAssertEqual(context["screenWidth"] as! Int, 640)
        XCTAssertEqual(context["screenHeight"] as! Int, 480)
    }
    
    func testDefaults() {
        let context = ScreenContextPlugin().captureContext(Context())
        
        let screenSize = UIScreen.main.bounds.size
        XCTAssertEqual(context["screenWidth"] as! Int, Int(screenSize.width))
        XCTAssertEqual(context["screenHeight"] as! Int, Int(screenSize.height))
    }
}
