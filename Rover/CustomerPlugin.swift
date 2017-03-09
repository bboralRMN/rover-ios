//
//  CustomerPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-05.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverData

struct CustomerPlugin: Plugin {
    
    static var dependencies: [AnyPlugin.Type] {
        return [AnyPlugin.Type]()
    }
    
    static func register(dispatcher: Any) {
        
    }
    
    static func reduce(state: Customer, action: Action, resolver: Resolver) -> Customer {
        switch action {
        case let action as SetCustomerIDAction:
            var nextState = state
            nextState.customerID = action.customerID
            return nextState
        default:
            return state
        }
    }
}
