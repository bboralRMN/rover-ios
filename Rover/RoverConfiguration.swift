//
//  RoverConfiguration.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

public struct RoverConfiguration {
    
    var apiURL: URL
    
    var apiToken: String
    
    var flushAt: Int
    
    var maxBatchSize: Int
    
    var maxQueueSize: Int
    
    init(apiURL: URL = URL(string: "https://api.rover.io/graphql")!, apiToken: String, flushAt: Int = 20, maxBatchSize: Int = 100, maxQueueSize: Int = 1000) {
        self.apiURL = apiURL
        self.apiToken = apiToken
        self.flushAt = flushAt
        self.maxBatchSize = maxBatchSize
        self.maxQueueSize = maxQueueSize
    }
}
