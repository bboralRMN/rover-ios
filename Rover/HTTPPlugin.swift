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
    
    static var dependencies: [AnyPlugin.Type] {
        return [AnyPlugin.Type]()
    }
    
    static func register(dispatcher: Any) {
        
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

// MARK: Actions

struct AddAuthorizerAction: Action {
    
    let authorizer: Authorizer
}

// MARK: Rover Extensions

extension Rover {
    
    func addAuthorizer(_ authorizer: Authorizer) {
        let action = AddAuthorizerAction(authorizer: authorizer)
        reduce(action: action)
    }
}
