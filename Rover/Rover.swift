//
//  Rover.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

public class Rover {
    
    public static let shared = Rover()
    
    var plugins = PluginMap()
}

// MARK: PluginResolver

extension Rover: PluginResolver {
    
    public func resolve<T: Plugin>(_ pluginType: T.Type, name: String? = nil) -> T? {
        typealias Factory = (PluginResolver) -> T
        let key = PluginKey(factoryType: Factory.self, name: name)
        
        guard let entry = plugins[key] as? PluginEntry<T>, let factory = entry.factory as? Factory else {
            return nil
        }
        
        return factory(self)
    }
}

// MARK: PluginContainer

extension Rover: PluginContainer {
    
    @discardableResult public func register<T>(_ pluginType: T.Type, name: String? = nil, factory: @escaping (PluginResolver) -> T) -> PluginEntry<T> {
        let key = PluginKey(factoryType: type(of: factory), name: nil)
        let entry = PluginEntry(pluginType: pluginType, factory: factory)
        plugins[key] = entry
        return entry
    }
}
