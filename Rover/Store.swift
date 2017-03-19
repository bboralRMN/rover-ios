//
//  Store.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverLogger

protocol Store {
    
    associatedtype Service
    
    var currentState: Service? { get }
    
    func register(resolver: Resolver, dispatcher: Dispatcher) -> Self
    
    func reduce(action: Action, resolver: Resolver) -> Self
    
    func isChanged(by action: Action) -> Bool
}

// MARK: AnyStore

struct AnyStore: Store {
    
    let currentState: Any?
    
    let registerHandler: (Resolver, Dispatcher) -> AnyStore
    
    let reduceHandler: (Action, Resolver) -> AnyStore
    
    let isChangedHandler: (Action) -> Bool
    
    init<T: Store>(_ store: T) {
        currentState = store.currentState
        
        registerHandler = { resolver, dispatcher in
            let registeredStore = store.register(resolver: resolver, dispatcher: dispatcher)
            return AnyStore(registeredStore)
        }
        
        reduceHandler = { (action, resolver) in
            let nextStore = store.reduce(action: action, resolver: resolver)
            return AnyStore(nextStore)
        }
        
        isChangedHandler = { action in
            return store.isChanged(by: action)
        }
    }
    
    func register(resolver: Resolver, dispatcher: Dispatcher) -> AnyStore {
        return registerHandler(resolver, dispatcher)
    }
    
    func reduce(action: Action, resolver: Resolver) -> AnyStore {
        return reduceHandler(action, resolver)
    }
    
    func isChanged(by action: Action) -> Bool {
        return isChangedHandler(action)
    }
}
