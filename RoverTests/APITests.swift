//
//  APITests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-28.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

import Rover
import RoverData

class APITests: XCTestCase {
    
    func testAssembly() {
        Rover.shared.register(AuthPlugin.self) { _ in
            return AuthPlugin(accountToken: "giberish")
        }
        
        Rover.shared.register(CustomerPlugin.self) { _ in
            return CustomerPlugin()
        }
        
        Rover.shared.register(HTTPPlugin.self) { resolver in
            let authPlugin = resolver.resolve(AuthPlugin.self)!
            let customerPlugin = resolver.resolve(CustomerPlugin.self)!
            return HTTPPlugin(authorizers: [authPlugin, customerPlugin])
        }
        
        Rover.shared.register(ApplicationContextPlugin.self) { _ in
            return ApplicationContextPlugin()
        }
        
        Rover.shared.register(EventsPlugin.self) { resolver in
            let httpPlugin = resolver.resolve(HTTPPlugin.self)!
            let applicationContextPlugin = resolver.resolve(ApplicationContextPlugin.self)!
            return EventsPlugin(taskFactory: httpPlugin, contextProviders: [applicationContextPlugin])
        }
        
        let httpPlugin = Rover.shared.resolve(HTTPPlugin.self)!
        XCTAssertEqual(httpPlugin.authorizers.count, 2)
    }
}
