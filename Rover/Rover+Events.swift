//
//  Rover+Events.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

extension Rover {
    
    public func addContextProvider(_ contextProvider: ContextProvider) {
        let action = AddContextProviderAction(contextProvider: contextProvider)
        reduce(action: action)
    }
    
    public func trackEvent(name: String, attributes: Attributes? = nil) {
        guard let eventsManager = resolve(EventsPlugin.self) else {
            return
        }
        
        eventsManager.trackEvent(name: name, attributes: attributes)
    }
    
    public func flushEvents() {
        guard let eventsManager = resolve(EventsPlugin.self) else {
            return
        }
        
        eventsManager.flushEvents()
    }
}
