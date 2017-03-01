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
        let apiClient = APIClient(baseURL: configuration.baseURL)
        let contextProvider = AmalgamatedContext(providers: configuration.contextProviders)
        
        eventManager = EventManager(flushAt: configuration.flushAt,
                                    flushInterval: configuration.flushInterval,
                                    maxQueueSize: configuration.maxQueueSize,
                                    maxBatchSize: configuration.maxBatchSize,
                                    apiClient: apiClient,
                                    contextProvider: contextProvider)
    }
}
