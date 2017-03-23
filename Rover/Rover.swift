//
//  Rover.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData
import RoverLogger

typealias ServiceMap = [ServiceKey: ServiceStore]

public class Rover {
    
    public static var shared = Rover()
    
    public static func assemble(accountToken: String) {
        let rover = Rover()
        
        do {
            try rover.register(HTTPService.self, factory: HTTPServiceFactory(accountToken: accountToken))
            try rover.register(EventsService.self, factory: EventsServiceFactory())
            try rover.register(Customer.self, factory: CustomerFactory())
        } catch {
            logger.error(error.localizedDescription)
        }
        
        shared = rover
    }
    
    var serviceMap = ServiceMap()
    
    var registeredServices = [ServiceKey]()
}

extension Rover: Container {
    
    func register<T: Service, U: ServiceFactory>(_ serviceType: T.Type, factory: U, name: String?) throws where U.Service == T {
        let serviceKey = ServiceKey(serviceType: serviceType, name: name)
        
        guard !registeredServices.contains(serviceKey) else {
            throw ServiceRegistrationError.alreadyRegistered(serviceKey: serviceKey)
        }
        
        let initialState = try factory.register(resolver: self, dispatcher: self)
        let anyFactory = AnyServiceFactory(factory)
        
        serviceMap[serviceKey] = ServiceStore(factory: anyFactory, currentState: initialState, hasChanged: false)
        registeredServices.append(serviceKey)
    }
}

extension Rover: Dispatcher {
    
    func dispatch(action: Action) {
        serviceMap = registeredServices.reduce(serviceMap, { (serviceMap, serviceKey) -> ServiceMap in
            guard let store = serviceMap[serviceKey] else {
                logger.error("No store found for serviceKey: \(serviceKey)")
                return serviceMap
            }
            
            guard let currentState = store.currentState else {
                logger.error("Missing current state for service \(serviceKey)")
                return serviceMap
            }
            
            struct LocalResolver: Resolver {
                let serviceMap: ServiceMap
            }
            
            let localResolver = LocalResolver(serviceMap: serviceMap)
            
            let nextState = store.factory.reduce(state: currentState, action: action, resolver: localResolver)
            let areEqual = store.factory.areEqual(a: store.currentState, b: nextState)
            let nextStore = ServiceStore(factory: store.factory, currentState: nextState, hasChanged: !areEqual)
            
            var nextServiceMap = serviceMap
            nextServiceMap[serviceKey] = nextStore
            return nextServiceMap
        })
    }
}

extension Rover: Resolver { }
