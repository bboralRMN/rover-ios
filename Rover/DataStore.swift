//
//  DataStore.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-01.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData

struct DataStore {
    
    typealias RegisterHandler = (Resolver, Dispatcher) -> DataStore
    
    let httpFactory: HTTPFactory?
    
    let registerHandler: RegisterHandler?
    
    init(httpFactory: HTTPFactory? = nil, registerHandler: RegisterHandler? = nil) {
        self.httpFactory = httpFactory
        self.registerHandler = registerHandler
    }
}

extension DataStore: Store {
    
    var currentState: HTTPFactory? {
        return httpFactory
    }
    
    func register(resolver: Resolver, dispatcher: Dispatcher) -> DataStore {
        if let registerHandler = registerHandler {
            return registerHandler(resolver, dispatcher)
        }
        
        let httpFactory = HTTPFactory()
        return DataStore(httpFactory: httpFactory)
    }
    
    func reduce(action: Action, resolver: Resolver) -> DataStore {
        switch action {
        case let action as AddAuthorizerAction:
            var nextAuthorizers = currentState?.authorizers ?? [Authorizer]()
            nextAuthorizers.append(action.authorizer)
            let httpFactory = HTTPFactory(baseURL: currentState?.baseURL,
                                          session: currentState?.session,
                                          path: currentState?.path,
                                          authorizers: nextAuthorizers)
            return DataStore(httpFactory: httpFactory)
        default:
            return self
        }
    }
    
    func isChanged(by action: Action) -> Bool {
        switch action {
        case _ as AddAuthorizerAction:
            return true
        default:
            return false
        }
    }
}
