//
//  ServiceFactory.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverLogger

protocol ServiceFactory {
    
    associatedtype Service
    
    func register(resolver: Resolver, dispatcher: Dispatcher) throws -> Service
    
    func reduce(state: Service, action: Action, resolver: Resolver) -> Service
    
    func areEqual(a: Service?, b: Service?) -> Bool
}

// MARK: AnyServiceFactory

struct AnyServiceFactory: ServiceFactory {
    
    private let registerHandler: (Resolver, Dispatcher) throws -> Any
    
    private let reduceHandler: (Any, Action, Resolver) -> Any
    
    private let areEqualHandler: (Any?, Any?) -> Bool
    
    init<T: ServiceFactory>(_ factory: T) {
        registerHandler = { resolver, dispatcher in
            return try factory.register(resolver: resolver, dispatcher: dispatcher)
        }
        
        reduceHandler = { (state, action, resolver) in
            return factory.reduce(state: state as! T.Service, action: action, resolver: resolver)
        }
        
        areEqualHandler = { a, b in
            return factory.areEqual(a: a as? T.Service, b: b as? T.Service)
        }
    }
    
    func register(resolver: Resolver, dispatcher: Dispatcher) throws -> Any {
        return try registerHandler(resolver, dispatcher)
    }
    
    func reduce(state: Any, action: Action, resolver: Resolver) -> Any {
        return reduceHandler(state, action, resolver)
    }
    
    func areEqual(a: Any?, b: Any?) -> Bool {
        return areEqualHandler(a, b)
    }
}
