//
//  ApplicationContextPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverLogger

public struct ApplicationContextPlugin {
    
    var bundle: BundleType
    
    init(bundle: BundleType? = nil) {
        self.bundle = bundle ?? Bundle.main
    }
    
    public init() {
        self.init(bundle: nil)
    }
}

extension ApplicationContextPlugin: Plugin {
    
    public var name: String {
        return "ApplicationContextPlugin"
    }
    
    public func register(rover: Rover) {
        
    }
}

extension ApplicationContextPlugin: ContextProvider {
    
    var info: [String: Any] {
        var info = [String: Any]()
        
        if let infoDictionary = bundle.infoDictionary {
            for (key, value) in infoDictionary {
                info[key] = value
            }
        } else {
            logger.warn("Failed to load infoDictionary from main bundle")
        }
        
        if let localizedInfoDictionary = bundle.localizedInfoDictionary {
            for (key, value) in localizedInfoDictionary {
                info[key] = value
            }
        } else {
            logger.warn("Failed to load localizedInfoDictionary from main bundle")
        }
        
        return info
    }
    
    public func captureContext(_ context: Context) -> Context {
        var nextContext = context
        
        if let name = info["CFBundleDisplayName"] as? String {
            nextContext["appName"] = name
        } else {
            logger.warn("Missing CFBundleDisplayName")
        }
        
        if let version = info["CFBundleShortVersionString"] as? String {
            nextContext["appVersion"] = version
        } else {
            logger.warn("Missing CFBundleShortVersionString")
        }
        
        if let build = info["CFBundleVersion"] as? String {
            nextContext["appBuild"] = build
        } else {
            logger.warn("Missing CFBundleVersion")
        }
        
        if let namespace = bundle.bundleIdentifier {
            nextContext["appNamespace"] = namespace
        } else {
            logger.warn("Missing bundleIdentifier")
        }
        
        return nextContext
    }
}

// MARK: BundleType

protocol BundleType {
    
    var infoDictionary: [String: Any]? { get }
    
    var localizedInfoDictionary: [String: Any]? { get }
    
    var bundleIdentifier: String? { get }
}

extension Bundle: BundleType { }
