//
//  ReachabilityContextPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverLogger

public struct ReachabilityContextPlugin {
    
    var reachability: ReachabilityType?
    
    init(reachability: ReachabilityType? = nil) {
        self.reachability = reachability ?? Reachability(hostname: "google.com")
    }
    
    public init() {
        self.init(reachability: nil)
    }
}

extension ReachabilityContextPlugin: Plugin {
    
    public var name: String {
        return "ReachabilityContextPlugin"
    }
    
    public func register(rover: Rover) {
        
    }
}

extension ReachabilityContextPlugin: ContextProvider {
    
    public func captureContext(_ context: Context) -> Context {
        guard let reachability = self.reachability else {
            logger.warn("Could not determine reachability")
            return context
        }
        
        var nextContext = context
        nextContext["isWifiEnabled"] = reachability.isReachableViaWiFi
        nextContext["isCellularEnabled"] = reachability.isReachableViaWWAN
        return nextContext
    }
}

// MARK: ReachabilityType

protocol ReachabilityType {
    var isReachableViaWiFi: Bool { get }
    var isReachableViaWWAN: Bool { get }
}

extension Reachability: ReachabilityType { }
