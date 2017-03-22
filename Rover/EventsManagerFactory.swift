//
//  EventsManagerFactory.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-05.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData
import RoverLogger

struct EventsManagerFactory { }

extension EventsManagerFactory: ServiceFactory {
    
    func register(resolver: Resolver, dispatcher: Dispatcher) throws -> EventsManager {
        guard let httpService = resolver.resolve(HTTPService.self) else {
            throw ServiceRegistrationError.unmetDependency(serviceType: HTTPService.self, dependencyType: HTTPService.self)
        }
        
        return EventsManager(uploadService: httpService)
    }
    
    func reduce(state: EventsManager, action: Action, resolver: Resolver) -> EventsManager {
        switch action {
        case let action as AddContextProviderAction:
            state.contextProviders.append(action.contextProvider)
        default:
            break
        }
        
        // TODO: Only update this if it has changed
        
        if let service = resolver.resolve(HTTPService.self) {
            state.uploadService = service
        }
        
        return state
    }
    
    func areEqual(a: EventsManager?, b: EventsManager?) -> Bool {
        return a === b
    }
}
