//
//  DataStore.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-01.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData
import RoverLogger

struct DataStore {
    
    let accountToken: String
    
    let deviceIdentifier: DeviceIdentifier
    
    let httpFactory: HTTPFactory?
    
    typealias RegisterHandler = (Resolver, Dispatcher) -> DataStore
    
    let registerHandler: RegisterHandler?
    
    init(accountToken: String, deviceIdentifier: DeviceIdentifier? = nil, httpFactory: HTTPFactory? = nil, registerHandler: RegisterHandler? = nil) {
        self.deviceIdentifier = deviceIdentifier ?? UIDevice.current
        self.accountToken = accountToken
        self.httpFactory = httpFactory
        self.registerHandler = registerHandler
    }
}

extension DataStore: Store {
    
    var currentState: HTTPFactory? {
        return httpFactory
    }
    
    func register(resolver: Resolver, dispatcher: Dispatcher) -> DataStore {
        if let registerHandler = registerHandler {
            return registerHandler(resolver, dispatcher)
        }
        
        var authHeaders = [AuthHeader(headerField: "x-rover-account-token", value: accountToken)]
        
        if let deviceId = deviceIdentifier.identifierForVendor?.uuidString {
            let deviceIdHeader = AuthHeader(headerField: "x-rover-device-id", value: deviceId)
            authHeaders.append(deviceIdHeader)
        } else {
            logger.warn("Failed to obtain identifierForVendor")
        }
        
        let httpFactory = HTTPFactory(authHeaders: authHeaders)
        
        return DataStore(accountToken: accountToken,
                         deviceIdentifier: deviceIdentifier,
                         httpFactory: httpFactory,
                         registerHandler: registerHandler)
    }
    
    func reduce(action: Action, resolver: Resolver) -> DataStore {
        switch action {
        case let action as AddAuthHeaderAction:
            var nextAuthHeaders = currentState?.authHeaders ?? [AuthHeader]()
            nextAuthHeaders.append(action.authHeader)
            
            let httpFactory = HTTPFactory(baseURL: currentState?.baseURL,
                                          session: currentState?.session,
                                          path: currentState?.path,
                                          authHeaders: nextAuthHeaders)
            
            return DataStore(accountToken: accountToken,
                             deviceIdentifier: deviceIdentifier,
                             httpFactory: httpFactory,
                             registerHandler: registerHandler)
        default:
            return self
        }
    }
    
    func isChanged(by action: Action) -> Bool {
        switch action {
        case _ as AddAuthHeaderAction:
            return true
        default:
            return false
        }
    }
}

// MARK: DeviceIdentifier

protocol DeviceIdentifier {
    
    var identifierForVendor: UUID? { get }
}

extension UIDevice: DeviceIdentifier { }
