//
//  Assembler.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

public protocol Assembler {
    
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
    
    public func assemble(container: Container) {
        container.register(AuthPlugin.self) { _ in
            return AuthPlugin(accountToken: "giberish")
        }
        
        container.register(CustomerPlugin.self) { _ in
            return CustomerPlugin()
        }
        
        container.register(HTTPPlugin.self) { (resolver, _) in
            let authPlugin = resolver.resolve(AuthPlugin.self)!
            let customerPlugin = resolver.resolve(CustomerPlugin.self)!
            return HTTPPlugin(authorizers: [authPlugin, customerPlugin])
        }
        
        container.register(ApplicationContextPlugin.self) { _ in
            return ApplicationContextPlugin()
        }
        
        container.register(DeviceContextPlugin.self) { _ in
            return DeviceContextPlugin()
        }
        
        container.register(FrameworkContextPlugin.self) { _ in
            let identifiers = [
                "io.rover.Rover",
                "io.rover.RoverData",
                "io.rover.RoverLogger"
            ]
            return FrameworkContextPlugin(identifiers: identifiers)
        }
        
        container.register(LocaleContextPlugin.self) { _ in
            return LocaleContextPlugin()
        }
        
        container.register(ScreenContextPlugin.self) { _ in
            return ScreenContextPlugin()
        }
        
        container.register(TelephonyContextPlugin.self) { _ in
            return TelephonyContextPlugin()
        }
        
        container.register(TimeZoneContextPlugin.self) { _ in
            return TimeZoneContextPlugin()
        }
        
        container.register(ReachabilityContextPlugin.self) { _ in
            return ReachabilityContextPlugin()
        }
        
        container.register(EventsPlugin.self) { (resolver, prevResult) in
            let httpPlugin = resolver.resolve(HTTPPlugin.self)!
            
            let contextProviders: [ContextProvider] = [
                resolver.resolve(ApplicationContextPlugin.self)!,
                resolver.resolve(DeviceContextPlugin.self)!,
                resolver.resolve(FrameworkContextPlugin.self)!,
                resolver.resolve(LocaleContextPlugin.self)!,
                resolver.resolve(ScreenContextPlugin.self)!,
                resolver.resolve(TelephonyContextPlugin.self)!,
                resolver.resolve(TimeZoneContextPlugin.self)!,
                resolver.resolve(ReachabilityContextPlugin.self)!
            ]
            
            // Treat EventsPlugin as a singleton
            
            if let prevEventsPlugin = prevResult {
                prevEventsPlugin.taskFactory = httpPlugin
                prevEventsPlugin.contextProviders = contextProviders
                return prevEventsPlugin
            }
            
            return EventsPlugin(taskFactory: httpPlugin, contextProviders: contextProviders)
        }
    }
}
