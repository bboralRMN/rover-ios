//
//  ApplicationContextPluginTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class ApplicationContextPluginTests: XCTestCase {
    
    struct TestBundle: BundleType {
        var infoDictionary: [String: Any]?
        var localizedInfoDictionary: [String: Any]?
        var bundleIdentifier: String?
        
        init(infoDictionary: [String: Any]? = nil, localizedInfoDictionary: [String: Any]? = nil, bundleIdentifier: String? = nil) {
            self.infoDictionary = infoDictionary
            self.localizedInfoDictionary = localizedInfoDictionary
            self.bundleIdentifier = bundleIdentifier
        }
    }
    
    func testCapture() {
        let infoDictionary: [String: Any] = [
            "CFBundleDisplayName": "Rover",
            "CFBundleShortVersionString": "2.0.0",
            "CFBundleVersion": "1"
        ]
        
        let bundle = TestBundle(infoDictionary: infoDictionary, bundleIdentifier: "io.rover.Rover")
        let context = ApplicationContextPlugin(bundle: bundle).captureContext(Context())
        
        XCTAssertEqual(context["appName"] as! String, "Rover")
        XCTAssertEqual(context["appVersion"] as! String, "2.0.0")
        XCTAssertEqual(context["appBuild"] as! String, "1")
        XCTAssertEqual(context["appNamespace"] as! String, "io.rover.Rover")
    }
    
    func testMergesLocalizedInfo() {
        let infoDictionary: [String: Any] = [
            "CFBundleDisplayName": "Rover",
            "CFBundleShortVersionString": "2.0.0",
            "CFBundleVersion": "1"
        ]
        
        let spanishInfoDictionary: [String: Any] = [
            "CFBundleDisplayName": "VagabundoContexto"
        ]
        
        let bundle = TestBundle(infoDictionary: infoDictionary, localizedInfoDictionary: spanishInfoDictionary, bundleIdentifier: "io.rover.Rover")
        let context = ApplicationContextPlugin(bundle: bundle).captureContext(Context())
        
        XCTAssertEqual(context["appName"] as! String, "VagabundoContexto")
        XCTAssertEqual(context["appVersion"] as! String, "2.0.0")
        XCTAssertEqual(context["appBuild"] as! String, "1")
        XCTAssertEqual(context["appNamespace"] as! String, "io.rover.Rover")
    }
    
    func testAllowsNilValues() {
        let infoDictionary = [String: Any]()
        let localizedInfoDictionary = [String: Any]()
        let bundle = TestBundle(infoDictionary: infoDictionary, localizedInfoDictionary: localizedInfoDictionary, bundleIdentifier: nil)
        let context = ApplicationContextPlugin(bundle: bundle).captureContext(Context())
        
        XCTAssertNil(context["appName"] as? String)
        XCTAssertNil(context["appVersion"] as? String)
        XCTAssertNil(context["appBuild"] as? String)
        XCTAssertNil(context["appNamespace"] as? String)
    }
}
