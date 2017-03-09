//
//  CustomerIDAuthorizer.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-09.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverData

public struct CustomerIDAuthorizer {
    
    let customerID: String
}

extension CustomerIDAuthorizer: Authorizer {
    
    public func authorize(_ request: URLRequest) -> URLRequest {
        var nextRequest = request
        nextRequest.addValue(customerID, forHTTPHeaderField: "x-rover-customer-id")
        return nextRequest
    }
}
