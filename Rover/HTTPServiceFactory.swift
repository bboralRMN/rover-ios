//
//  HTTPServiceFactory.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-01.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData
import RoverLogger

struct HTTPServiceFactory {
    
    let accountToken: String
    
    let baseURL: URL?
    
    let session: HTTPSession?
    
    let path: String?
    
    let authHeaders: [AuthHeader]?
    
    let deviceIdentifier: DeviceIdentifier
    
    init(accountToken: String,
         baseURL: URL? = nil, 
         session: HTTPSession? = nil, 
         path: String? = nil,
         authHeaders: [AuthHeader]? = nil,
         deviceIdentifier: DeviceIdentifier? = nil) {
        
        self.accountToken = accountToken
        self.baseURL = baseURL
        self.session = session
        self.path = path
        self.authHeaders = authHeaders
        self.deviceIdentifier = deviceIdentifier ?? UIDevice.current
    }
}

extension HTTPServiceFactory: ServiceFactory {
    
    func register(resolver: Resolver, dispatcher: Dispatcher) throws -> HTTPService {
        guard let deviceId = deviceIdentifier.identifierForVendor?.uuidString else {
            throw ServiceRegistrationError.unexpectedCondition(description: "Failed to obtain identifierForVendor")
        }
        
        var authHeaders = self.authHeaders ?? [AuthHeader]()
        
        let accountTokenAuthHeader = AuthHeader(headerField: "x-rover-account-token", value: accountToken)
        authHeaders.append(accountTokenAuthHeader)
        
        let deviceIdAuthHeader = AuthHeader(headerField: "x-rover-device-id", value: deviceId)
        authHeaders.append(deviceIdAuthHeader)
        
        return HTTPService(baseURL: baseURL, session: session, path: path, authHeaders: authHeaders)
    }
    
    func reduce(state: HTTPService, action: Action, resolver: Resolver) -> HTTPService {
        switch action {
        case let action as AddAuthHeaderAction:
            var nextAuthHeaders = state.authHeaders
            nextAuthHeaders.append(action.authHeader)
            
            return HTTPService(baseURL: state.baseURL,
                               session: state.session,
                               path: state.path,
                               authHeaders: nextAuthHeaders)
        default:
            return state
        }
    }
    
    func areEqual(a: HTTPService?, b: HTTPService?) -> Bool {
        return a == b
    }
}

// MARK: DeviceIdentifier

protocol DeviceIdentifier {
    
    var identifierForVendor: UUID? { get }
}

extension UIDevice: DeviceIdentifier { }
