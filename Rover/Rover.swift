//
//  Rover.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverContext
import RoverData
import RoverEvents

open class Rover {
    
    static var _shared: Rover?
    
    public static var shared: Rover {
        guard let shared = _shared else {
            fatalError("Rover shared instance accessed before calling configure")
        }
        return shared
    }
    
    public static func configure(_ configuration: RoverConfiguration) {
        _shared = Rover(configuration: configuration)
    }
    
    var eventManager: EventManager
    
    init(configuration: RoverConfiguration) {
        let endpoint = HTTPEndpoint(url: configuration.apiURL, token: configuration.apiToken)
        let httpClient = HTTPClient(endpoint: endpoint)
        
        eventManager = EventManager(
            flushAt: configuration.flushAt,
            maxQueueSize: configuration.maxQueueSize,
            maxBatchSize: configuration.maxBatchSize,
            eventTransport: httpClient
        )
        
        eventManager.contextProvider = contextProvider()
    }
    
    open func contextProvider() -> ContextProvider? {
        let identifiers = [
            "io.rover.Rover",
            "io.rover.RoverContext",
            "io.rover.RoverData",
            "io.rover.RoverEvents",
            "io.rover.RoverLogger"
        ]
        
        let providers: [ContextProvider] = [
            ApplicationContext(),
            DeviceContext(),
            FrameworkContext(identifiers: identifiers),
            LocaleContext(),
            ScreenContext(),
            TelephonyContext(),
            TimeZoneContext(),
            ReachabilityContext()
        ]
        
        return AmalgamatedContext(providers: providers)
    }
}
