//
//  HTTPPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-01.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverData

struct HTTPPlugin: Plugin {
    
    typealias State = HTTPFactory
    
    static func register(dispatcher: Any) {
        
    }
    
    static func isChanged(by action: Action) -> Bool {
        switch action {
        case _ as AddAuthorizerAction:
            return true
        default:
            return false
        }
    }
    
    static func reduce(state: HTTPFactory, action: Action, resolver: Resolver) -> HTTPFactory {
        switch action {
        case let a as AddAuthorizerAction:
            var nextState = state
            nextState.authorizers.append(a.authorizer)
            return nextState
        default:
            return state
        }
    }
}
