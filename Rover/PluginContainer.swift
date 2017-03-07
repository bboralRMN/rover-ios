//
//  PluginContainer.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-06.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

public protocol PluginContainer {
    
    func register<T>(_ pluginType: T.Type, name: String?, factory: @escaping (PluginResolver) -> T) -> PluginEntry<T>
}
