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

typealias ServiceMap = [ServiceKey: AnyStore]

public class Rover {
    
    public static let shared = Rover()
    
    var serviceMap = ServiceMap()
    
    var registeredServices = [ServiceKey]()
}

extension Rover: Container {
    
    func register<T: Service, U: Store>(_ serviceType: T.Type, store: U, name: String?) where U.Service == T {
        let serviceKey = ServiceKey(serviceType: serviceType, name: name)
        
        guard !registeredServices.contains(serviceKey) else {
            logger.error("\(serviceKey) has already been registered")
            return
        }
        
        let registeredStore = store.register(resolver: self, dispatcher: self)        
        serviceMap[serviceKey] = AnyStore(registeredStore)
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
            
            var nextServiceMap = serviceMap
            nextServiceMap[serviceKey] = store.reduce(action: action, resolver: self)
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
