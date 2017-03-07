//
//  PluginContainer.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-06.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

public protocol PluginContainer {
    
    @discardableResult func register<T>(_ pluginType: T.Type, factory: @escaping (PluginResolver) -> T) -> PluginEntry<T>
    
    @discardableResult func register<T>(_ pluginType: T.Type, name: String?, factory: @escaping (PluginResolver) -> T) -> PluginEntry<T>
}

extension PluginContainer {
    
    @discardableResult public func register<T>(_ pluginType: T.Type, factory: @escaping (PluginResolver) -> T) -> PluginEntry<T> {
        return register(pluginType, name: nil, factory: factory)
    }
}
