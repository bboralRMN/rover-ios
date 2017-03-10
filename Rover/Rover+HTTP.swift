//
//  Rover+HTTP.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverData

extension Rover {
    
    func addAuthorizer(_ authorizer: Authorizer) {
        let action = AddAuthorizerAction(authorizer: authorizer)
        reduce(action: action)
    }
}
