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
    
    func assemble(rover: Rover)
}

// MARK: DefaultAssembler

public struct DefaultAssembler {
    
    public var accountToken: String
    
    public init(accountToken: String) {
        self.accountToken = accountToken
    }
}

extension DefaultAssembler: Assembler {

    func assemble(rover: Rover) {
        rover.register(Customer.self, store: CustomerStore())
        rover.register(HTTPFactory.self, store: DataStore(accountToken: accountToken))
        rover.register(EventsManager.self, store: EventsStore())
        
        // TODO: Move this into the register function of the CustomerStore
        
        if let customer = rover.resolve(Customer.self, name: nil), let authHeader = customer.authHeader {
            rover.addAuthHeader(authHeader)
        }
        
        // TODO: Move this into the register function of the EventsStore
        
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

        for contextProvider in contextProviders {
            rover.addContextProvider(contextProvider)
        }
    }
}
