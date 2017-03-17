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
    
    static func register(dispatcher: Any) {
        
    }
    
    static func isChanged(by action: Action) -> Bool {
        switch action {
        case _ as SetCustomerIDAction:
            return true
        default:
            return false
        }
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
