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

// MARK: Container

public protocol Container {
    
    @discardableResult func register<T: Plugin>(_ pluginType: T.Type, factory: @escaping (Resolver, T?) -> T) -> PluginEntry<T>
    
    @discardableResult func register<T: Plugin>(_ pluginType: T.Type, name: String?, factory: @escaping (Resolver, T?) -> T) -> PluginEntry<T>
}

extension Container {
    
    @discardableResult public func register<T: Plugin>(_ pluginType: T.Type, factory: @escaping (Resolver, T?) -> T) -> PluginEntry<T> {
        return register(pluginType, name: nil, factory: factory)
    }
}

extension Rover: Container {
    
    @discardableResult public func register<T: Plugin>(_ pluginType: T.Type, name: String?, factory: @escaping (Resolver, T?) -> T) -> PluginEntry<T> {
        let key = PluginKey(factoryType: type(of: factory), name: nil)
        
        let prevEntry = plugins[key] as? PluginEntry<T>
        let entry = PluginEntry(pluginType: pluginType, factory: factory, prevResult: prevEntry?.prevResult)
        plugins[key] = entry
        return entry
    }
}

// MARK: Resolver

public protocol Resolver {
    
    func resolve<T: Plugin>(_ pluginType: T.Type) -> T?
    
    func resolve<T: Plugin>(_ pluginType: T.Type, name: String?) -> T?
}

extension Resolver {
    
    public func resolve<T: Plugin>(_ pluginType: T.Type) -> T? {
        return resolve(pluginType, name: nil)
    }
}

extension Rover: Resolver {
    
    public func resolve<T: Plugin>(_ pluginType: T.Type, name: String? = nil) -> T? {
        typealias Factory = (Resolver, T?) -> T
        let key = PluginKey(factoryType: Factory.self, name: name)
        
        guard let entry = plugins[key] as? PluginEntry<T>, let factory = entry.factory as? Factory else {
            return nil
        }
        
        let result = factory(self, entry.prevResult)
        plugins[key] = PluginEntry(pluginType: entry.pluginType, factory: entry.factory, prevResult: result)
        return result
    }
}
