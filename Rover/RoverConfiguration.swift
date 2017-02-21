//
//  RoverConfiguration.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverContext

open class RoverConfiguration {
    
    var apiURL: URL
    
    var apiToken: String
    
    var flushAt: Int
    
    var maxBatchSize: Int
    
    var maxQueueSize: Int
    
    var contextProviders: [ContextProvider]
    
    init(apiURL: URL = URL(string: "https://api.rover.io/graphql")!, apiToken: String, flushAt: Int = 20, maxBatchSize: Int = 100, maxQueueSize: Int = 1000, contextProviders: [ContextProvider]? = nil) {
        self.apiURL = apiURL
        self.apiToken = apiToken
        self.flushAt = flushAt
        self.maxBatchSize = maxBatchSize
        self.maxQueueSize = maxQueueSize
        
        if let contextProviders = contextProviders {
            self.contextProviders = contextProviders
        } else {
            let identifiers = [
                "io.rover.Rover",
                "io.rover.RoverContext",
                "io.rover.RoverData",
                "io.rover.RoverEvents",
                "io.rover.RoverLogger"
            ]
            
            self.contextProviders = [
                ApplicationContext(),
                DeviceContext(),
                FrameworkContext(identifiers: identifiers),
                LocaleContext(),
                ScreenContext(),
                TelephonyContext(),
                TimeZoneContext(),
                ReachabilityContext()
            ]
        }
    }
}
