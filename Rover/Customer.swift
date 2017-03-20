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
    
    let firstName: String?
    
    let lastName: String?
    
    let email: String?
    
    let gender: SyncResult.Gender?
    
    var age: Int?
    
    var phoneNumber: String?
    
    var tags: [String]?
    
    var traits: JSON?
    
    init(customerID: String? = nil,
         firstName: String? = nil,
         lastName: String? = nil,
         email: String? = nil,
         gender: SyncResult.Gender? = nil,
         age: Int? = nil,
         phoneNumber: String? = nil,
         tags: [String]? = nil,
         traits: JSON? = nil) {
        
        self.customerID = customerID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.gender = gender
        self.age = age
        self.phoneNumber = phoneNumber
        self.tags = tags
        self.traits = traits
    }
}

extension Customer {
    
    var authorizer: Authorizer? {
        guard let customerID = customerID else {
            return nil
        }
        
        return CustomerIDAuthorizer(customerID: customerID)
    }
}
