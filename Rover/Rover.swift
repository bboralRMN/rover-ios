//
//  Rover.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData
import RoverLogger

public class Rover {
    
    public static let shared = Rover()
    
    var pluginMap = PluginMap()
    
    var registeredPlugins = [PluginKey]()
}

extension Rover: Container {
    
    func register<T : Plugin>(_ pluginType: T.Type, initialState: T.State) {
        let key = PluginKey(pluginType: pluginType, name: nil)
        
        guard !registeredPlugins.contains(key) else {
            logger.error("Attempted to register plugin after it has already been registered: \(pluginType)")
            return
        }
        
        let isDependenciesMet = T.dependencies.reduce(true) { (result, pluginType) -> Bool in
            let key = PluginKey(pluginType: pluginType, name: nil)
            return result && registeredPlugins.contains(key)
        }
        
        guard isDependenciesMet else {
            logger.error("Unmet dependencies found while registering plugin: \(pluginType)")
            return
        }
        
        pluginMap[key] = initialState
        registeredPlugins.append(key)
    }
}

extension Rover: Reducer {
    
    func reduce(action: Action) {
        pluginMap = registeredPlugins.reduce(pluginMap, { (map, key) -> PluginMap in
            guard let state = map[key] else {
                logger.error("Invalid state for plugin: \(key.pluginType)")
                return map
            }
            
            var nextMap = map
            nextMap[key] = key.pluginType.reduce(state: state, action: action, resolver: self)
            return nextMap
        })
    }
}

extension Rover: Resolver {
    
    func resolve<T: Plugin>(_ pluginType: T.Type, name: String?) -> T.State? {
        let key = PluginKey(pluginType: pluginType, name: name)
        return pluginMap[key] as? T.State
    }
}
