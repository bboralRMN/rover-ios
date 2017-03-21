//
//  Customer.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-09.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData

public struct Customer {
    
    public let customerID: String?
    
    public let firstName: String?
    
    public let lastName: String?
    
    public let email: String?
    
    public let gender: SyncResult.Gender?
    
    public let age: Int?
    
    public let phoneNumber: String?
    
    public let tags: [String]?
    
    public let traits: JSON?
    
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
    
    var authHeader: AuthHeader? {
        guard let customerID = customerID else {
            return nil
        }
        return AuthHeader(headerField: "x-rover-customer-id", value: customerID)
    }
}
