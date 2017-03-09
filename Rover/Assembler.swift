//
//  Assembler.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverData

protocol Assembler {
    
    func assemble(container: Container)
}

// MARK: DefaultAssembler

public struct DefaultAssembler {
    
    public var accountToken: String
    
    public init(accountToken: String) {
        self.accountToken = accountToken
    }
}

extension DefaultAssembler: Assembler {

    func assemble(container: Container) {
        let customer = Customer()
        container.register(CustomerPlugin.self, initialState: customer)
        
        var authorizers: [Authorizer] = [
            AccountTokenAuthorizer(accountToken: accountToken),
            DeviceIDAuthorizer()
        ]
        
        if let customerIDAuthorizer = customer.authorizer {
            authorizers.append(customerIDAuthorizer)
        }
        
        let httpFactory = HTTPFactory(authorizers: authorizers)
        container.register(HTTPPlugin.self, initialState: httpFactory)
        
        let frameworkIdentifiers = [
            "io.rover.Rover",
            "io.rover.RoverData",
            "io.rover.RoverLogger"
        ]

        let contextProviders: [ContextProvider] = [
            ApplicationContextProvider(),
            DeviceContextProvider(),
            FrameworkContextProvider(identifiers: frameworkIdentifiers),
            LocaleContextProvider(),
            ScreenContextProvider(),
            TelephonyContextProvider(),
            TimeZoneContextProvider(),
            ReachabilityContextProvider()
        ]
        
        let eventsManager = EventsManager(taskFactory: httpFactory, contextProviders: contextProviders)
        container.register(EventsPlugin.self, initialState: eventsManager)
    }
}
