//
//  Container.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-09.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

protocol Container {
    
    func register<T: Service, U: Store>(_ serviceType: T.Type, store: U, name: String?) where U.Service == T
    
    func register<T: Service, U: Store>(_ serviceType: T.Type, store: U) where U.Service == T
}

extension Container {
    
    func register<T: Service, U: Store>(_ serviceType: T.Type, store: U) where U.Service == T {
        return register(serviceType, store: store, name: nil)
    }
}
