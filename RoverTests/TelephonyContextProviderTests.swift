//
//  TelephonyContextProviderTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class TelephonyContextProviderTests: XCTestCase {
    
    struct TestCarrier: CarrierType {
        var carrierName: String?
    }
    
    struct TestTelephonyNetworkInfo: TelephonyNetworkInfoType {
        var currentRadioAccessTechnology: String?
    }
    
    func testCapture() {
        let carrier = TestCarrier(carrierName: "Rogers")
        let telephonyNetworkInfo = TestTelephonyNetworkInfo(currentRadioAccessTechnology: "LTE")
        let context = TelephonyContextProvider(telephonyNetworkInfo: telephonyNetworkInfo, carrier: carrier).captureContext(Context())
        
        XCTAssertEqual(context["carrierName"] as! String, "Rogers")
        XCTAssertEqual(context["radio"] as! String, "LTE")
    }
    
    func testPrefixedRadio() {
        let telephonyNetworkInfo = TestTelephonyNetworkInfo(currentRadioAccessTechnology: "CTRadioAccessTechnologyLTE")
        let context = TelephonyContextProvider(telephonyNetworkInfo: telephonyNetworkInfo).captureContext(Context())
        
        XCTAssertEqual(context["radio"] as! String, "LTE")
    }
    
    func testNoRadio() {
        let telephonyNetworkInfo = TestTelephonyNetworkInfo(currentRadioAccessTechnology: nil)
        let context = TelephonyContextProvider(telephonyNetworkInfo: telephonyNetworkInfo).captureContext(Context())
        
        XCTAssertEqual(context["radio"] as! String, "None")
    }
}
