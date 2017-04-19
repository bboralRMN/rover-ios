//
//  Rover+assemble.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-31.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverEvents
import RoverFoundation
import RoverHTTP
import RoverSync
import RoverUser

public class Rover: Facade {
    
    public static func assemble(accountToken: String) -> Rover {
        let assemblers: [Assembler] = [
            HTTPAssembler(accountToken: accountToken),
            EventsAssembler(),
            SyncAssembler(),
            UserAssembler()
        ]
        
        return assemble(assemblers) as! Rover
    }
}

// MARK: Events

extension Rover {
    
    public func trackEvent(name: String, attributes: Attributes? = nil) {
        let operation = TrackEventOperation(name: name, attributes: attributes)
        addOperation(operation)
    }
}

// MARK: Sync

extension Rover {
    
    public var currentUser: User? {
        return container.resolve(SyncState.self)?.user
    }
    
    public func sync(completionHandler: (() -> Void)?) {
        let operation = SyncOperation()
        addOperation(operation) { _ in
            completionHandler?()
        }
    }
}

// MARK: User 

extension Rover {

    public func anonymizeUser() {
        let operation = AnonymizeUserOperation()
        addOperation(operation)
    }
    
    public func identifyUser(userID: UserID) {
        let operation = IdentifyUserOperation(userID: userID)
        addOperation(operation)
    }
    
    public func updateUser(updates: [UserUpdate], completionHandler: ((User?) -> Void)?) {
        let operation = UpdateUserOperation(updates: updates)
        addOperation(operation) { _ in
            completionHandler?(self.currentUser)
        }
    }
}
