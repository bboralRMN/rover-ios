//
//  RoverConfiguration.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverContext

public class RoverConfiguration {
    
    var baseURL: URL
    
    var accountToken: String
    
    var flushAt: Int
    
    var flushInterval: Double
    
    var maxBatchSize: Int
    
    var maxQueueSize: Int
    
    var contextProviders: [ContextProvider]
    
    public init(baseURL: URL = URL(string: "https://api.rover.io/graphql")!, accountToken: String, flushAt: Int = 20, flushInterval: Double = 30.0, maxBatchSize: Int = 100, maxQueueSize: Int = 1000, contextProviders: [ContextProvider]? = nil) {
        self.baseURL = baseURL
        self.accountToken = accountToken
        self.flushAt = flushAt
        self.flushInterval = flushInterval
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
