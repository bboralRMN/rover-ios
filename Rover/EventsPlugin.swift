//
//  EventsPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-05.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverLogger
import RoverData

public typealias EventsPlugin = EventsManager

extension EventsPlugin { }

// MARK: Rover

//extension Rover {
//    
//    public func trackEvent(name: String, attributes: Attributes? = nil) {
//        guard let eventsPlugin = resolve(EventsPlugin.self) else {
//            return
//        }
//        
//        eventsPlugin.trackEvent(name: name, attributes: attributes)
//    }
//    
//    public func flushEvents() {
//        guard let eventsPlugin = resolve(EventsPlugin.self) else {
//            return
//        }
//        
//        eventsPlugin.flushEvents()
//    }
//}
