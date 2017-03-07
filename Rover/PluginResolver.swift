//
//  PluginResolver.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-06.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

public protocol PluginResolver {
    
    func resolve<T: Plugin>(_ pluginType: T.Type) -> T?
    
    func resolve<T: Plugin>(_ pluginType: T.Type, name: String?) -> T?
}

extension PluginResolver {
    
    public func resolve<T : Plugin>(_ pluginType: T.Type) -> T? {
        return resolve(pluginType, name: nil)
    }
}
