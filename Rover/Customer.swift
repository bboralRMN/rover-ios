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
    
    var storage: CustomerIDStorage
    
    public init() {
        self.init(storage: nil)
    }
    
    init(storage: CustomerIDStorage?) {
        self.storage = storage ?? UserDefaults.standard
    }
}

extension Customer {
    
    var customerID: String? {
        get {
            return storage.customerID
        }
        set {
            storage.customerID = newValue
        }
    }
    
    var authorizer: Authorizer? {
        guard let customerID = customerID else {
            return nil
        }
        
        return CustomerIDAuthorizer(customerID: customerID)
    }
}

protocol CustomerIDStorage {
    
    var customerID: String? { get set }
}

extension UserDefaults: CustomerIDStorage {
    
    var customerID: String? {
        get {
            return string(forKey: "io.rover.customerID")
        }
        set {
            set(newValue, forKey: "io.rover.customerID")
        }
    }
}
