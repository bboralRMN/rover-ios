//
//  Plugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverLogger

// MARK: Plugin

protocol AnyPlugin {
    
    static var dependencies: [AnyPlugin.Type]? { get }
    
    static func register(dispatcher: Any)
    
    static func isChanged(by action: Action) -> Bool
    
    static func reduce(state: Any, action: Action, resolver: Resolver) -> Any
}

extension AnyPlugin {
    
    static var dependencies: [AnyPlugin.Type]? {
        return nil
    }
}
protocol Plugin: AnyPlugin {
    
    associatedtype State
    
    static func reduce(state: State, action: Action, resolver: Resolver) -> State
}

extension Plugin {
    
    static func reduce(state: Any, action: Action, resolver: Resolver) -> Any {
        guard let typedState = state as? State else {
            logger.error("Attempt to reduce invalid state type: \(type(of: state))")
            return state
        }
        
        return reduce(state: typedState, action: action, resolver: resolver)
    }
}

// MARK: PluginKey

struct PluginKey {
    
    let pluginType: AnyPlugin.Type
    
    let name: String?
}

extension PluginKey: Hashable {
    
    var hashValue: Int {
        return String(describing: pluginType).hashValue ^ (name?.hashValue ?? 0)
    }
}

func == (lhs: PluginKey, rhs: PluginKey) -> Bool {
    return lhs.pluginType == rhs.pluginType && lhs.name == rhs.name
}

// MARK: PluginMap

typealias PluginMap = [PluginKey: Any]
