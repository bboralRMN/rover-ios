//
//  Rover+assemble.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-31.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverEvents
import RoverFoundation
import RoverHTTP
import RoverSync
import RoverUser

class Rover: Container {
    
    static var _shared: Rover?
    
    public static var shared: Rover {
        guard let shared = _shared else {
            fatalError("Rover.shared accessed before calling assemble")
        }
        
        return shared
    }
    
    public static func assemble(accountToken: String) {
        let rover = Rover()
        
        do {
            let httpFactory = HTTPClientFactory(accountToken: accountToken)
            
            try rover.register(EventsDataService.self, factory: httpFactory)
            try rover.register(EventsManagerService.self, factory: EventsManagerFactory())
            
            try rover.register(SyncDataService.self, factory: httpFactory)
            
            try rover.register(UserDataService.self, factory: httpFactory)
            try rover.register(UserService.self, factory: UserFactory())
        } catch {
            logger.error(error.localizedDescription)
        }
        
        _shared = rover
    }
    
    var serviceMap = ServiceMap()
    
    var registeredServices = [ServiceKey]()
}
