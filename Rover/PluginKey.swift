//
//  PluginKey.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

struct PluginKey {
    
    var factoryType: PluginFactory.Type
    
    var name: String?
}

// MARK: Hashable

extension PluginKey: Hashable {
    
    var hashValue: Int {
        return String(describing: factoryType).hashValue ^ (name?.hashValue ?? 0)
    }
}

// MARK: Equatable

func == (lhs: PluginKey, rhs: PluginKey) -> Bool {
    return lhs.factoryType == rhs.factoryType && lhs.name == rhs.name
}
