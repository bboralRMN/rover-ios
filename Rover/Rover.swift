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
            try rover.register(Customer.self, factory: CustomerFactory())
            try rover.register(HTTPService.self, factory: HTTPServiceFactory(accountToken: accountToken))
            try rover.register(EventsManager.self, factory: EventsManagerFactory())
        } catch {
            logger.error(error.localizedDescription)
        }
        
        // TODO: Move this into the register function of the CustomerStore
        
        if let customer = rover.resolve(Customer.self), let authHeader = customer.authHeader {
            rover.addAuthHeader(authHeader)
        }
        
        // TODO: Move this into the register function of the EventsStore
        
        let frameworkIdentifiers = [
            "io.rover.Rover",
            "io.rover.RoverData",
            "io.rover.RoverLogger"
        ]
        
        let contextProviders: [ContextProvider] = [
            ApplicationContextProvider(),
            DeviceContextProvider(),
            FrameworkContextProvider(identifiers: frameworkIdentifiers),
            LocaleContextProvider(),
            ScreenContextProvider(),
            TelephonyContextProvider(),
            TimeZoneContextProvider(),
            ReachabilityContextProvider()
        ]
        
        for contextProvider in contextProviders {
            rover.addContextProvider(contextProvider)
        }
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
            
            let nextState = store.factory.reduce(state: currentState, action: action, resolver: self)
            let areEqual = store.factory.areEqual(a: store.currentState, b: nextState)
            let nextStore = ServiceStore(factory: store.factory, currentState: nextState, hasChanged: !areEqual)
            
            var nextServiceMap = serviceMap
            nextServiceMap[serviceKey] = nextStore
            return nextServiceMap
        })
    }
}

extension Rover: Resolver {
    
    func resolve<T: Service>(_ serviceType: T.Type, name: String?) -> T? {
        let serviceKey = ServiceKey(serviceType: serviceType, name: name)
        let store = serviceMap[serviceKey]
        return store?.currentState as? T
    }
}
