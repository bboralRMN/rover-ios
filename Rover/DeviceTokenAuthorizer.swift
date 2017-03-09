//
//  DeviceTokenAuthorizer.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-09.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverData
import RoverLogger

public struct DeviceIDAuthorizer {
    
    let deviceIdentifier: DeviceIdentifier
    
    public init() {
        self.init(deviceIdentifier: nil)
    }
    
    init(deviceIdentifier: DeviceIdentifier?) {
        self.deviceIdentifier = deviceIdentifier ?? UIDevice.current
    }
}

extension DeviceIDAuthorizer: Authorizer {
    
    public func authorize(_ request: URLRequest) -> URLRequest {
        guard let deviceId = deviceIdentifier.identifierForVendor?.uuidString else {
            logger.warn("Failed to obtain identifierForVendor")
            return request
        }
        
        var nextRequest = request
        nextRequest.addValue(deviceId, forHTTPHeaderField: "x-rover-device-id")
        return nextRequest
    }
}

// MARK: DeviceIdentifier

protocol DeviceIdentifier {
    
    var identifierForVendor: UUID? { get }
}

extension UIDevice: DeviceIdentifier { }
