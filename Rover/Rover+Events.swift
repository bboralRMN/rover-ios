//
//  Rover+Events.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData

extension Rover {
    
    public func addContextProvider(_ contextProvider: ContextProvider) {
        let action = AddContextProviderAction(contextProvider: contextProvider)
        dispatch(action: action)
    }
    
    public func trackEvent(name: String, attributes: Attributes? = nil) {
        guard let eventsService = resolve(EventsService.self), let httpService = resolve(HTTPService.self) else {
            return
        }
        
        eventsService.trackEvent(name: name, attributes: attributes, authHeaders: httpService.authHeaders)
    }
    
    public func flushEvents() {
        guard let eventsService = resolve(EventsService.self) else {
            return
        }
        
        eventsService.flushEvents()
    }
}
