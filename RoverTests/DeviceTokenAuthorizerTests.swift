//
//  DeviceTokenAuthorizerTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class DeviceTokenAuthorizerTests: XCTestCase {
    
    func testAuthorizeWithCustomIdentifier() {
        let uuidString = "D5CCF1E9-BEAA-46D0-AA1C-AF5027CB23F3"
        let uuid = UUID(uuidString: uuidString)!
        let deviceIdentifier = MockDeviceIdentifier(uuid: uuid)
        let authorizer = DeviceIDAuthorizer(deviceIdentifier: deviceIdentifier)
        let url = URL(string: "http://example.com")!
        let request = URLRequest(url: url)
        let result = authorizer.authorize(request)
        XCTAssertEqual(result.allHTTPHeaderFields!["x-rover-device-id"], uuidString)
    }
    
    func testAuthorizeWithCurrentDevice() {
        let deviceID = UIDevice.current.identifierForVendor!
        let authorizer = DeviceIDAuthorizer()
        let url = URL(string: "http://example.com")!
        let request = URLRequest(url: url)
        let result = authorizer.authorize(request)
        XCTAssertEqual(result.allHTTPHeaderFields!["x-rover-device-id"], deviceID.uuidString)
    }
}

fileprivate struct MockDeviceIdentifier: DeviceIdentifier {
    
    let uuid: UUID
    
    var identifierForVendor: UUID? {
        return uuid
    }
}
