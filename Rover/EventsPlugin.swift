//
//  EventsPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-05.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

struct EventsPlugin: Plugin {
    
    typealias State = EventsManager
    
    static var dependencies: [AnyPlugin.Type]? {
        return [HTTPPlugin.self]
    }
    
    static func register(dispatcher: Any) {
        
    }
    
    @discardableResult static func reduce(state: EventsManager, action: Action, resolver: Resolver) -> EventsManager {
        switch action {
        case let action as AddContextProviderAction:
            state.contextProviders.append(action.contextProvider)
        default:
            break
        }
        
        if let httpFactory = resolver.resolve(HTTPPlugin.self) {
            state.taskFactory = httpFactory
        }
        
        return state
    }
}
