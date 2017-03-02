//
//  LocaleContextPluginTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class LocaleContextPluginTests: XCTestCase {
    
    struct TestLocale: LocaleType {
        var languageCode: String?
        var regionCode: String?
        var scriptCode: String?
    }
    
    func testCapture() {
        let locale = TestLocale(languageCode: "zh", regionCode: "HK", scriptCode: "Hans")
        let context = LocaleContextPlugin(locale: locale).captureContext(Context())
        
        XCTAssertEqual(context["localeLanguage"] as! String, "zh")
        XCTAssertEqual(context["localeRegion"] as! String, "HK")
        XCTAssertEqual(context["localeScript"] as! String, "Hans")
    }
    
    func testNilValues() {
        let locale = TestLocale()
        let context = LocaleContextPlugin(locale: locale).captureContext(Context())
        
        XCTAssertNil(context["localeLanguage"] as? String)
        XCTAssertNil(context["localeRegion"] as? String)
        XCTAssertNil(context["localeScript"] as? String)
    }
}
