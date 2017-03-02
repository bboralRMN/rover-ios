//
//  Rover+Authorizer.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-01.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData

extension Rover: Authorizer {
    
    var authorizers: [Authorizer] {
        return plugins
            .map({ $0.1 as? Authorizer })
            .flatMap({ $0 })
    }
    
    public func authorize(_ request: URLRequest) -> URLRequest {
        return authorizers.reduce(request) { $1.authorize($0) }
    }
}
