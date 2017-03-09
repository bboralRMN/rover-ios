//
//  LocaleContextProvider.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverLogger

public struct LocaleContextProvider {
    
    var locale: LocaleType
    
    init(locale: LocaleType? = nil) {
        self.locale = locale ?? Locale.current
    }
    
    public init() {
        self.init(locale: nil)
    }
}

extension LocaleContextProvider: ContextProvider {
    
    public func captureContext(_ context: Context) -> Context {
        var nextContext = context
        
        if let localeLanguage = locale.languageCode {
            nextContext["localeLanguage"] = localeLanguage
        } else {
            logger.debug("localeLanguage not found")
        }
        
        if let localeRegion = locale.regionCode {
            nextContext["localeRegion"] = localeRegion
        } else {
            logger.debug("localeRegion not found")
        }
        
        if let localeScript = locale.scriptCode {
            nextContext["localeScript"] = localeScript
        } else {
            logger.debug("localeScript not found")
        }
        
        return nextContext
    }
}

// MARK: LocaleType

protocol LocaleType {
    
    var languageCode: String? { get }
    
    var regionCode: String? { get }
    
    var scriptCode: String? { get }
}

extension Locale: LocaleType { }
