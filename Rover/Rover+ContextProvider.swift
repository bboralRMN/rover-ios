//
//  Rover+ContextProvider.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-01.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

extension Rover: ContextProvider {
    
    var contextProviders: [ContextProvider] {
        return plugins
            .map({ $0.1 as? ContextProvider })
            .flatMap({ $0 })
    }
    
    public func captureContext(_ context: Context) -> Context {
        return contextProviders.reduce(context) { $1.captureContext($0) }
    }
}
