//
//  Event.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverData

struct Event {
    
    let eventId = UUID()
    
    let timestamp = Date()
    
    let name: String
    
    let attributes: Attributes?
    
    let context: Context?
    
    let authHeaders: [AuthHeader]?
    
    init(name: String,
         attributes: Attributes? = nil,
         context: Context? = nil,
         authHeaders: [AuthHeader]? = nil) {
        
        self.name = name
        self.attributes = attributes
        self.context = context
        self.authHeaders = authHeaders
    }
}
