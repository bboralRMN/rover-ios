//
//  Event.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverData

public struct Event {
    
    // Auto-generated and should never change
    let eventId = UUID()
    
    public let timestamp = Date()
    
    public var name: String
    
    public var attributes: Attributes?
    
    public var context: Context?
    
    public init(name: String, attributes: Attributes? = nil, context: Context? = nil) {
        self.name = name
        self.attributes = attributes
        self.context = context
    }
}

extension Event: EventInputType { }
