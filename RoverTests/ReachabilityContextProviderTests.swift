//
//  ReachabilityContextProviderTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class ReachabilityContextProviderTests: XCTestCase {
    
    func testCapture() {
        
        struct TestReachability: ReachabilityType {
            var isReachableViaWiFi: Bool
            var isReachableViaWWAN: Bool
        }
        
        let reachability = TestReachability(isReachableViaWiFi: true, isReachableViaWWAN: false)
        let context = ReachabilityContextProvider(reachability: reachability).captureContext(Context())
        
        XCTAssertTrue(context["isWifiEnabled"] as! Bool)
        XCTAssertFalse(context["isCellularEnabled"] as! Bool)
    }
}
