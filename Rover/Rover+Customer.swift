//
//  Rover+Customer.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-09.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

extension Rover {
    
    public func setCustomerID(_ customerID: String) {
        let action = SetCustomerIDAction(customerID: customerID)
        reduce(action: action)
        
        guard let authorizer = resolve(CustomerPlugin.self)?.authorizer else {
            return
        }
        
        addAuthorizer(authorizer)
    }
}
