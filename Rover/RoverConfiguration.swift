//
//  RoverConfiguration.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

public class RoverConfiguration {
    
    var baseURL: URL
    
    var accountToken: String
    
    var flushAt: Int
    
    var flushInterval: Double
    
    var maxBatchSize: Int
    
    var maxQueueSize: Int
    
    var plugins: [Plugin]
    
    public init(baseURL: URL = URL(string: "https://api.rover.io/graphql")!, accountToken: String, flushAt: Int = 20, flushInterval: Double = 30.0, maxBatchSize: Int = 100, maxQueueSize: Int = 1000, plugins: [Plugin]? = nil) {
        self.baseURL = baseURL
        self.accountToken = accountToken
        self.flushAt = flushAt
        self.flushInterval = flushInterval
        self.maxBatchSize = maxBatchSize
        self.maxQueueSize = maxQueueSize
        
        if let plugins = plugins {
            self.plugins = plugins
        } else {
            let identifiers = [
                "io.rover.Rover",
                "io.rover.RoverData",
                "io.rover.RoverLogger"
            ]

            self.plugins = [
                ApplicationContextPlugin(),
                DeviceContextPlugin(),
                FrameworkContextPlugin(identifiers: identifiers),
                LocaleContextPlugin(),
                ScreenContextPlugin(),
                TelephonyContextPlugin(),
                TimeZoneContextPlugin(),
                ReachabilityContextPlugin()
            ]
        }
    }
}
