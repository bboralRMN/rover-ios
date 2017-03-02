//
//  Rover+Plugins.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-02.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

typealias PluginMap = [String: Plugin]

public protocol Plugin {
    
    var name: String { get }
    
    func register(rover: Rover)
}

extension Rover {
    
    func register(_ plugin: Plugin) -> Plugin? {
        plugin.register(rover: self)
        return plugin
    }

    func addToMap(_ map: PluginMap, plugin: Plugin?) -> PluginMap {
        guard let plugin = plugin else {
            return map
        }
        
        var nextMap = map
        nextMap[plugin.name] = plugin
        return nextMap
    }
}
