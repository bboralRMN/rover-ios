//
//  DeviceContextPluginTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class DeviceContextPluginTests: XCTestCase {
    
    struct TestDevice: DeviceType {
        var systemName: String
        var systemVersion: String
        var identifierForVendor: UUID?
        
        init(systemName: String = "iOS", systemVersion: String = "10.2.1", identifierForVendor: UUID? = nil) {
            self.systemName = systemName
            self.systemVersion = systemVersion
            self.identifierForVendor = identifierForVendor
        }
    }
    
    func testCapture() {
        let uuid = UUID()
        let device = TestDevice(identifierForVendor: uuid)
        let context = DeviceContextPlugin(device: device).captureContext(Context())
        
        XCTAssertEqual(context["deviceManufacturer"] as! String, "Apple")
        XCTAssertEqual(context["osName"] as! String, "iOS")
        XCTAssertEqual(context["osVersion"] as! String, "10.2.1")
        XCTAssertEqual(context["deviceId"] as? String, uuid.uuidString)
        XCTAssertNotNil(context["deviceModel"] as? String)
    }
    
    func testAllowsNilIdentifierForVendor() {
        let device = TestDevice()
        let context = DeviceContextPlugin(device: device).captureContext(Context())
        
        XCTAssertNil(context["deviceId"] as? String)
    }
}
