//
//  CustomerStore.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-05.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData

struct CustomerStore {
    
    let customer: Customer?
    
    let localStorage: LocalStorage
    
    init(customer: Customer? = nil, localStorage: LocalStorage? = nil) {
        self.customer = customer
        self.localStorage = localStorage ?? UserDefaults.standard
    }
}

extension CustomerStore: Store {
    
    var currentState: Customer? {
        return customer
    }
    
    func register(resolver: Resolver, dispatcher: Dispatcher) -> CustomerStore {
        let customerID = localStorage.string(forKey: "io.rover.customerID")
        let customer = Customer(customerID: customerID)
        return CustomerStore(customer: customer, localStorage: localStorage)
    }
    
    func reduce(action: Action, resolver: Resolver) -> CustomerStore {
        switch action {
        case let action as IdentifyCustomerAction:
            self.localStorage.set(action.customerID, forKey: "io.rover.customerID")
            let customer = Customer(customerID: action.customerID)
            return CustomerStore(customer: customer, localStorage: localStorage)
        default:
            return self
        }
    }
    
    func isChanged(by action: Action) -> Bool {
        switch action {
        case _ as IdentifyCustomerAction:
            return true
        default:
            return false
        }
    }
}

// MARK: LocalStorage

protocol LocalStorage {
    
    func string(forKey defaultName: String) -> String?
    
    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: LocalStorage { }
