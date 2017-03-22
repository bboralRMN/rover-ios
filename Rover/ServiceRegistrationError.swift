//
//  ServiceRegistrationError.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-22.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

enum ServiceRegistrationError: Error {
    case alreadyRegistered(serviceKey: ServiceKey)
    case unmetDependency(serviceType: Service.Type, dependencyType: Service.Type)
    case unexpectedCondition(description: String)
}

extension ServiceRegistrationError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case let .alreadyRegistered(serviceKey):
            return "\(serviceKey) has already been registered"
        case let .unmetDependency(serviceType, dependencyType):
            return "Failed to register \(serviceType) due to unmet dependency \(dependencyType)"
        case let .unexpectedCondition(description):
            return description
        }
    }
}
