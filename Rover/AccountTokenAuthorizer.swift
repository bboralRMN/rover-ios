//
//  AccountTokenAuthorizer.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-09.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverData

public struct AccountTokenAuthorizer {
    
    let accountToken: String
}

extension AccountTokenAuthorizer: Authorizer {
    
    public func authorize(_ request: URLRequest) -> URLRequest {
        var nextRequest = request
        nextRequest.addValue(accountToken, forHTTPHeaderField: "x-rover-account-token")
        return nextRequest
    }
}
