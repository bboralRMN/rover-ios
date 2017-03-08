//
//  AuthPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverData
import RoverLogger

public struct AuthPlugin {
    
    var deviceIdentifier: DeviceIdentifier
    
    public var accountToken: String
    
    public init(accountToken: String) {
        self.init(accountToken: accountToken, deviceIdentifier: nil)
    }
    
    init(accountToken: String, deviceIdentifier: DeviceIdentifier?) {
        self.accountToken = accountToken
        self.deviceIdentifier = deviceIdentifier ?? UIDevice.current
    }
}

extension AuthPlugin: Authorizer {
    
    public func authorize(_ request: URLRequest) -> URLRequest {
        var nextRequest = request
        nextRequest.addValue(accountToken, forHTTPHeaderField: "x-rover-account-token")
        
        if let deviceId = deviceIdentifier.identifierForVendor?.uuidString {
            nextRequest.addValue(deviceId, forHTTPHeaderField: "x-rover-device-id")
        } else {
            logger.warn("Failed to obtain identifierForVendor")
        }
        
        return nextRequest
    }
}

// MARK: DeviceIdentifier

protocol DeviceIdentifier {
    
    var identifierForVendor: UUID? { get }
}

extension UIDevice: DeviceIdentifier { }
