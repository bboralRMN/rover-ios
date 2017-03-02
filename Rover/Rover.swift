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

open class Rover {
    
    static var _shared: Rover?
    
    var plugins = PluginMap()
    
    var apiClient: APIClient
    
    var eventManager: EventManager
    
    init(configuration: RoverConfiguration) {
        apiClient = APIClient(baseURL: configuration.baseURL)
        
        eventManager = EventManager(flushAt: configuration.flushAt,
                                    flushInterval: configuration.flushInterval,
                                    maxQueueSize: configuration.maxQueueSize,
                                    maxBatchSize: configuration.maxBatchSize,
                                    apiClient: apiClient)
        
        plugins = configuration.plugins
            .map(register)
            .reduce(plugins, addToMap)
        
        apiClient.authorizer = self
        eventManager.contextProvider = self
    }
}

// MARK: Configuration

extension Rover {
    
    public static var shared: Rover {
        guard let shared = _shared else {
            fatalError("Rover shared instance accessed before calling configure")
        }
        return shared
    }
    
    public static func configure(_ configuration: RoverConfiguration) {
        guard _shared == nil else {
            logger.error("Rover can only be configured once")
            return
        }
        _shared = Rover(configuration: configuration)
    }
}
