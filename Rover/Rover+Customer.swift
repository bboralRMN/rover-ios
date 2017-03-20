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
        let action = IdentifyCustomerAction(customerID: customerID)
        dispatch(action: action)
        
        if let customer = resolve(Customer.self), let authorizer = customer.authorizer {
            addAuthorizer(authorizer)
        }
    }
    
    public func updateCustomer(_ updates: [CustomerUpdate]) {
        let attributes = ["updates": updates.map { $0.serialized }]
        trackEvent(name: "Customer Update", attributes: attributes)
    }
    
    public func getCustomer() -> Customer? {
        return resolve(Customer.self, name: nil)
    }
}
