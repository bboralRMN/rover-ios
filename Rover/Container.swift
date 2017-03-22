//
//  Container.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-09.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

protocol Container {
    
    func register<T: Service, U: ServiceFactory>(_ serviceType: T.Type, factory: U, name: String?) throws where U.Service == T
    
    func register<T: Service, U: ServiceFactory>(_ serviceType: T.Type, factory: U) throws where U.Service == T
}

extension Container {
    
    func register<T: Service, U: ServiceFactory>(_ serviceType: T.Type, factory: U) throws where U.Service == T {
        return try register(serviceType, factory: factory, name: nil)
    }
}
