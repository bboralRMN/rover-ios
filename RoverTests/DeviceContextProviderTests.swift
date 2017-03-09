//
//  DeviceContextProviderTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class DeviceContextProviderTests: XCTestCase {
    
    struct MockSystemInfo: SystemInfo {
        var systemName: String
        var systemVersion: String
        
        init(systemName: String = "iOS", systemVersion: String = "10.2.1") {
            self.systemName = systemName
            self.systemVersion = systemVersion
        }
    }
    
    func testCapture() {
        let systemInfo = MockSystemInfo()
        let context = DeviceContextProvider(systemInfo: systemInfo).captureContext(Context())
        
        XCTAssertEqual(context["deviceManufacturer"] as! String, "Apple")
        XCTAssertEqual(context["osName"] as! String, "iOS")
        XCTAssertEqual(context["osVersion"] as! String, "10.2.1")
        XCTAssertNotNil(context["deviceModel"] as? String)
    }
}
