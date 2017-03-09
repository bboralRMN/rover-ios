//
//  Resolver.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-09.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

protocol Resolver {
    
    func resolve<T: Plugin>(_ pluginType: T.Type, name: String?) -> T.State?
    
    func resolve<T: Plugin>(_ pluginType: T.Type) -> T.State?
}

extension Resolver {
    
    func resolve<T: Plugin>(_ pluginType: T.Type) -> T.State? {
        return resolve(pluginType, name: nil)
    }
}
