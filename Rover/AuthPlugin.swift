//
//  AuthPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-01.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData
import RoverLogger

struct AuthPlugin {
    
    var accountToken: String
}

extension AuthPlugin: Plugin {
    
    public var name: String {
        return "AuthPlugin"
    }
    
    func register(rover: Rover) {
        
    }
}

extension AuthPlugin: Authorizer {
    
    func authorize(_ request: URLRequest) -> URLRequest {
        var nextRequest = request
        nextRequest.addValue(accountToken, forHTTPHeaderField: "x-rover-account-token")
        
        if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
            nextRequest.addValue(deviceId, forHTTPHeaderField: "x-rover-device-id")
        } else {
            logger.warn("Failed to obtain identifierForVendor")
        }
        
        return nextRequest
    }
}
