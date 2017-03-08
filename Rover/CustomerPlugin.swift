//
//  CustomerPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-05.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData

public struct CustomerPlugin {
    
    public var customerID: String?
    
    public init(customerID: String? = nil) {
        self.customerID = customerID
    }
}

extension CustomerPlugin: Authorizer {
    
    public func authorize(_ request: URLRequest) -> URLRequest {
        guard let customerID = customerID else {
            return request
        }
        
        var nextRequest = request
        nextRequest.addValue(customerID, forHTTPHeaderField: "x-rover-customer-id")
        return nextRequest
    }
}

//extension Rover {
//    
//    public func setCustomerID(_ customerID: String) {
//        register(CustomerPlugin.self) { _ in CustomerPlugin(customerID: customerID) }
//    }
//}
