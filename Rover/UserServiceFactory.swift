//
//  UserServiceFactory.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-05.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData
import RoverLogger

struct UserServiceFactory {
    
    let localStorage: LocalStorage
    
    init(localStorage: LocalStorage? = nil) {
        self.localStorage = localStorage ?? UserDefaults.standard
    }
}

extension UserServiceFactory: ServiceFactory {
    
    func register(resolver: Resolver, dispatcher: Dispatcher) throws -> UserService {
        guard let _ = resolver.resolve(HTTPService.self) else {
            throw ServiceRegistrationError.unmetDependency(serviceType: UserService.self, dependencyType: HTTPService.self)
        }
        
        let userID = localStorage.string(forKey: "io.rover.userID")
        let user = UserService(userID: userID)
        
        if let authHeader = user.authHeader {
            let action = AddAuthHeaderAction(authHeader: authHeader)
            dispatcher.dispatch(action: action)
        }
        
        return user
    }
    
    func reduce(state: UserService, action: Action, resolver: Resolver) -> UserService {
        switch action {
        case let action as IdentifyUserAction:
            localStorage.set(action.userID, forKey: "io.rover.userID")
            return UserService(userID: action.userID,
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
            case .success(let user):
                if let userID = state.userID {
                    guard user.userID == userID else {
                        logger.error("Unexpected user ID found in SyncResult")
                        return state
                    }
                } else {
                    self.localStorage.set(user.userID, forKey: "io.rover.userID")
                }
                
                return UserService(userID: user.userID,
                                   firstName: user.firstName,
                                   lastName: user.lastName,
                                   email: user.email,
                                   gender: user.gender,
                                   age: user.age,
                                   phoneNumber: user.phoneNumber,
                                   tags: user.tags,
                                   traits: user.traits)
            default:
                return state
            }
        default:
            return state
        }
    }
    
    func areEqual(a: UserService?, b: UserService?) -> Bool {
        return a == b
    }
}

// MARK: LocalStorage

protocol LocalStorage {
    
    func string(forKey defaultName: String) -> String?
    
    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: LocalStorage { }
