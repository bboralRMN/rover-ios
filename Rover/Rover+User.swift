//
//  Rover+User.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-09.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

extension Rover {
    
    public func setUserID(_ userID: String) {
        let action = IdentifyUserAction(userID: userID)
        dispatch(action: action)
        
        if let user = resolve(UserService.self), let authHeader = user.authHeader {
            addAuthHeader(authHeader)
        }
    }
    
    public func updateUser(_ updates: [UserUpdate]) {
        let attributes = ["updates": updates.map { $0.serialized }]
        trackEvent(name: "User Update", attributes: attributes)
    }
    
    public func currentUser() -> UserService? {
        return resolve(UserService.self, name: nil)
    }
}
