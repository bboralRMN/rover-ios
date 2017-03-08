////
////  PluginMap.swift
////  Rover
////
////  Created by Sean Rucker on 2017-03-07.
////  Copyright © 2017 Rover Labs Inc. All rights reserved.
////
//
//import Foundation
//
//// MARK: PluginMap
//
//typealias PluginMap = [PluginKey: PluginEntryType]
//
//// MARK: Plugin
//
//public protocol Plugin { }
//
//// MARK: Factory
//
//typealias Factory = Any
//
//// MARK: PluginKey
//
//struct PluginKey {
//    
//    var factoryType: Factory.Type
//    
//    var name: String?
//}
//
//extension PluginKey: Hashable {
//    
//    var hashValue: Int {
//        return String(describing: factoryType).hashValue ^ (name?.hashValue ?? 0)
//    }
//}
//
//func == (lhs: PluginKey, rhs: PluginKey) -> Bool {
//    return lhs.factoryType == rhs.factoryType && lhs.name == rhs.name
//}
//
//// MARK: PluginEntry
//
//protocol PluginEntryType { }
//
//public struct PluginEntry<T: Plugin> {
//    
//    let pluginType: T.Type
//    
//    let factory: Factory
//    
//    let prevResult: T?
//}
//
//extension PluginEntry: PluginEntryType { }
