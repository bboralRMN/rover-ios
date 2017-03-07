//
//  FrameworkContextPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

public struct FrameworkContextPlugin {
    
    var identifiers: [String]
    
    public init(identifiers: [String]) {
        self.identifiers = identifiers
    }
}

extension FrameworkContextPlugin: Plugin { }

typealias FrameworkIdentifier = String
typealias FrameworkVersion = String
typealias FrameworkMap = [FrameworkIdentifier: FrameworkVersion]

extension FrameworkContextPlugin: ContextProvider {
    
    public func captureContext(_ context: Context) -> Context {
        let frameworks = context["frameworks"] as? FrameworkMap ?? FrameworkMap()
        let nextFrameworks = identifiers.reduce(frameworks, addEntry)
        var nextContext = context
        nextContext["frameworks"] = nextFrameworks
        return nextContext
    }
    
    func addEntry(to prevMap: FrameworkMap, for identifier: FrameworkIdentifier) -> FrameworkMap {
        guard let bundle = Bundle(identifier: identifier) else {
            return prevMap
        }
        
        guard let dictionary = bundle.infoDictionary else {
            return prevMap
        }
        
        guard let version = dictionary["CFBundleShortVersionString"] as? String else {
            return prevMap
        }
        
        var nextMap = prevMap
        nextMap[identifier] = version
        return nextMap
    }
}
