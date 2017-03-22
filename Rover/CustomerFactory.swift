//
//  CustomerStore.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-05.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData
import RoverLogger

struct CustomerFactory {
    
    let localStorage: LocalStorage
    
    init(localStorage: LocalStorage? = nil) {
        self.localStorage = localStorage ?? UserDefaults.standard
    }
}

extension CustomerFactory: ServiceFactory {
    
    func register(resolver: Resolver, dispatcher: Dispatcher) -> Customer {
        let customerID = localStorage.string(forKey: "io.rover.customerID")
        return Customer(customerID: customerID)
    }
    
    func reduce(state: Customer, action: Action, resolver: Resolver) -> Customer {
        switch action {
        case let action as IdentifyCustomerAction:
            localStorage.set(action.customerID, forKey: "io.rover.customerID")
            return Customer(customerID: action.customerID,
                            firstName: state.firstName,
                            lastName: state.lastName,
                            email: state.email,
                            gender: state.gender,
                            age: state.age,
                            phoneNumber: state.phoneNumber,
                            tags: state.tags,
                            traits: state.traits)
        case let action as SyncCompleteAction:
            switch action.syncResult {
            case .success(let customer):
                if let customerID = state.customerID {
                    guard customer.customerID == customerID else {
                        logger.error("Unexpected customer ID found in SyncResult")
                        return state
                    }
                } else {
                    self.localStorage.set(customer.customerID, forKey: "io.rover.customerID")
                }
                
                return Customer(customerID: customer.customerID,
                                firstName: customer.firstName,
                                lastName: customer.lastName,
                                email: customer.email,
                                gender: customer.gender,
                                age: customer.age,
                                phoneNumber: customer.phoneNumber,
                                tags: customer.tags,
                                traits: customer.traits)
            default:
                return state
            }
        default:
            return state
        }
    }
    
    func areEqual(a: Customer?, b: Customer?) -> Bool {
        return a == b
    }
}

// MARK: LocalStorage

protocol LocalStorage {
    
    func string(forKey defaultName: String) -> String?
    
    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: LocalStorage { }
