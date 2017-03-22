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

extension Customer: Equatable {
    
    public static func == (lhs: Customer, rhs: Customer) -> Bool {
        guard lhs.customerID == rhs.customerID && lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName && lhs.email == rhs.email && lhs.gender == rhs.gender && lhs.age == rhs.age && lhs.phoneNumber == rhs.phoneNumber else {
            return false
        }
        
        if let a = lhs.tags {
            guard let b = rhs.tags, a == b else {
                return false
            }
        } else {
            guard rhs.tags == nil else {
                return false
            }
        }
        
        // TODO: Compare traits
        return true
    }
}
