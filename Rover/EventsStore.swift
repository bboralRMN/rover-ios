//
//  EventsStore.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-05.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData
import RoverLogger

struct EventsStore {
    
    typealias RegisterHandler = (Resolver, Dispatcher) -> EventsStore
    
    let eventsManager: EventsManager?
    
    let registerHandler: RegisterHandler?
    
    init(eventsManager: EventsManager? = nil, registerHandler: RegisterHandler? = nil) {
        self.eventsManager = eventsManager
        self.registerHandler = registerHandler
    }
}

extension EventsStore: Store {
    
    var currentState: EventsManager? {
        return eventsManager
    }
    
    func register(resolver: Resolver, dispatcher: Dispatcher) -> EventsStore {
        if let registerHandler = registerHandler {
            return registerHandler(resolver, dispatcher)
        }
        
        guard let httpFactory = resolver.resolve(HTTPFactory.self) else {
            logger.error("Attempted to register EventsStore before dependency HTTPFactory was registered")
            return self
        }
        
        let eventsManager = EventsManager(taskFactory: httpFactory)
        return EventsStore(eventsManager: eventsManager)
    }
    
    func reduce(action: Action, resolver: Resolver) -> EventsStore {
        guard let state = currentState else {
            logger.error("Unexpected nil state found while reducing EventsStore")
            return self
        }
        
        switch action {
        case let action as AddContextProviderAction:
            state.contextProviders.append(action.contextProvider)
        default:
            break
        }
        
        // TODO: Only update this if it has changed
        
        if let httpFactory = resolver.resolve(HTTPFactory.self) {
            state.taskFactory = httpFactory
        }
        
        return EventsStore(eventsManager: state)
    }
    
    func isChanged(by action: Action) -> Bool {
        switch action {
        case _ as AddContextProviderAction:
            return true
        default:
            return false
        }
    }
}
