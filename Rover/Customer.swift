//
//  Customer.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-09.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverData

struct Customer {
    
    let customerID: String?
    
    init(customerID: String? = nil) {
        self.customerID = customerID
    }
}

extension Customer: Equatable {
    
    static func == (lhs: Customer, rhs: Customer) -> Bool {
        return lhs.customerID == rhs.customerID
    }
    
    var authorizer: Authorizer? {
        guard let customerID = customerID else {
            return nil
        }
        
        return CustomerIDAuthorizer(customerID: customerID)
    }
}
