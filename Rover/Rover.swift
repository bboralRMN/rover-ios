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

public class Rover {
    
    static var _shared: Rover?
    
    static var shared: Rover {
        guard let shared = _shared else {
            fatalError("Shared instance accessed before calling assemble")
        }
        
        return shared
    }
    
    public static func assemble(accountToken: String) -> Rover {
        let assemblers: [Assembler] = [
            HTTPAssembler(accountToken: accountToken),
            EventsAssembler(),
            SyncAssembler(),
            UserAssembler()
        ]
        
        let container = Container(assemblers: assemblers)
        let rover = Rover(container: container)
        _shared = rover
        return rover
    }
    
    var container: Container
    
    init(container: Container) {
        self.container = container
    }
}

// MARK: HTTP

extension Rover {
    
    public static func addIdentifier(identifier: Identifier) {
        let operation = AddIdentifierOperation(identifier: identifier)
        shared.container.addOperation(operation)
    }
    
    public static func configureHTTP(baseURL: URL?, session: HTTPSession?, path: String?) {
        let operation = ConfigureHTTPOperation(baseURL: baseURL, session: session, path: path)
        shared.container.addOperation(operation)
    }
    
    public static func removeIdentifier(name: Identifier.Name) {
        let operation = RemoveIdentifierOperation(name: name)
        shared.container.addOperation(operation)
    }
}

// MARK: Events

extension Rover {
    
    public static func addContextProviders(contextProviders: [ContextProvider]) {
        let operation = AddContextProvidersOperation(contextProviders: contextProviders)
        shared.container.addOperation(operation)
    }
    
    public static func configureEvents(flushAt: Int?, maxBatchSize: Int?, maxQueueSize: Int?) {
        let operation = ConfigureEventsOperation(flushAt: flushAt, maxBatchSize: maxBatchSize, maxQueueSize: maxQueueSize)
        shared.container.addOperation(operation)
    }
    
    public static func flushEvents() {
        let operation = FlushEventsOperation(minBatchSize: 1)
        shared.container.addOperation(operation)
    }
    
    public static func trackEvent(name: String, attributes: Attributes? = nil) {
        let operation = TrackEventOperation(name: name, attributes: attributes)
        shared.container.addOperation(operation)
    }
}

// MARK: Sync

extension Rover {
    
    public static func sync() {
        let operation = SyncOperation()
        shared.container.addOperation(operation)
    }
}

// MARK: User

extension Rover {
    
    public static func anonymizeUser() {
        let operation = AnonymizeUserOperation()
        shared.container.addOperation(operation)
    }
    
    public static func identifyUser(userID: UserID) {
        let operation = IdentifyUserOperation(userID: userID)
        shared.container.addOperation(operation)
    }
    
    public static func updateUser(updates: [UserUpdate]) {
        let operation = UpdateUserOperation(updates: updates)
        shared.container.addOperation(operation)
    }
}
