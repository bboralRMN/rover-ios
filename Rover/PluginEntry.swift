//
//  PluginEntry.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

protocol PluginEntryType { }

public struct PluginEntry<T: Plugin> {
    
    let pluginType: T.Type
    
    let factory: PluginFactory
}

extension PluginEntry: PluginEntryType { }

