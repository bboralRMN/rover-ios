//
//  ScreenContextProvider.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

public struct ScreenContextProvider {
    
    var screenSize: CGSize
    
    init(screenSize: CGSize? = nil) {
        self.screenSize = screenSize ?? UIScreen.main.bounds.size
    }
    
    public init() {
        self.init(screenSize: nil)
    }
}

extension ScreenContextProvider: ContextProvider {
    
    public func captureContext(_ context: Context) -> Context {
        var nextContext = context
        nextContext["screenWidth"] = Int(screenSize.width)
        nextContext["screenHeight"] = Int(screenSize.height)
        return nextContext
    }
}
