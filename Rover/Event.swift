//
//  Event.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverContext
import RoverData

struct Event {
    
    // Auto-generated and should never change
    let eventId = UUID()
    let timestamp = Date()
    
    var name: String
    var attributes: Attributes?
    var context: Context?
    
    init(name: String, attributes: Attributes? = nil, context: Context? = nil) {
        self.name = name
        self.attributes = attributes
        self.context = context
    }
}

extension Event: EventInputType { }
