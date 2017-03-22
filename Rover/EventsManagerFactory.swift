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

struct EventsManagerFactory {

    let contextProviders: [ContextProvider]?
    
    let flushAt: Int?
    
    let flushInterval: Double?
    
    let maxBatchSize: Int?
    
    let maxQueueSize: Int?
    
    init(contextProviders: [ContextProvider]? = nil,
         flushAt: Int? = nil,
         flushInterval: Double? = nil,
         maxBatchSize: Int? = nil,
         maxQueueSize: Int? = nil) {
        
        self.contextProviders = contextProviders ?? {
            let frameworkIdentifiers = [
                "io.rover.Rover",
                "io.rover.RoverData",
                "io.rover.RoverLogger"
            ]
            
            return [
                ApplicationContextProvider(),
                DeviceContextProvider(),
                FrameworkContextProvider(identifiers: frameworkIdentifiers),
                LocaleContextProvider(),
                ScreenContextProvider(),
                TelephonyContextProvider(),
                TimeZoneContextProvider(),
                ReachabilityContextProvider()
            ]
        }()
        
        self.flushAt = flushAt
        self.flushInterval = flushInterval
        self.maxBatchSize = maxBatchSize
        self.maxQueueSize = maxQueueSize
    }
}

extension EventsManagerFactory: ServiceFactory {
    
    func register(resolver: Resolver, dispatcher: Dispatcher) throws -> EventsManager {
        guard let httpService = resolver.resolve(HTTPService.self) else {
            throw ServiceRegistrationError.unmetDependency(serviceType: HTTPService.self, dependencyType: HTTPService.self)
        }
        
        return EventsManager(uploadService: httpService,
                             contextProviders: contextProviders,
                             flushAt: flushAt,
                             flushInterval: flushInterval,
                             maxBatchSize: maxBatchSize,
                             maxQueueSize: maxQueueSize)
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
