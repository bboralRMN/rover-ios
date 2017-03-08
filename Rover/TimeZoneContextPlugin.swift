//
//  TimeZoneContextPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

public struct TimeZoneContextPlugin {
    
    var timeZone: TimeZoneType
    
    init(timeZone: TimeZoneType? = nil) {
        self.timeZone = timeZone ?? NSTimeZone.local as NSTimeZone
    }
    
    public init() {
        self.init(timeZone: nil)
    }
}

extension TimeZoneContextPlugin: ContextProvider {
    
    public func captureContext(_ context: Context) -> Context {
        var nextContext = context
        nextContext["timeZone"] = timeZone.name
        return nextContext
    }
}

// MARK: TimeZoneType

protocol TimeZoneType {
    var name: String { get }
}

extension NSTimeZone: TimeZoneType { }
