//
//  Resolver.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-09.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

protocol Resolver {
    
    func resolve<T: Service>(_ serviceType: T.Type, name: String?) -> T?
    
    func resolve<T: Service>(_ serviceType: T.Type) -> T?
}

extension Resolver {
    
    func resolve<T: Service>(_ serviceType: T.Type) -> T? {
        return resolve(serviceType, name: nil)
    }
}
