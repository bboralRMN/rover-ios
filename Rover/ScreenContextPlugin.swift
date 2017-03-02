//
//  ScreenContextPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

public struct ScreenContextPlugin {
    
    var screenSize: CGSize
    
    init(screenSize: CGSize? = nil) {
        self.screenSize = screenSize ?? UIScreen.main.bounds.size
    }
    
    public init() {
        self.init(screenSize: nil)
    }
}

extension ScreenContextPlugin: Plugin {
    
    public var name: String {
        return "ScreenContextPlugin"
    }
    
    public func register(rover: Rover) {
        
    }
}

extension ScreenContextPlugin: ContextProvider {
    
    public func captureContext(_ context: Context) -> Context {
        var nextContext = context
        nextContext["screenWidth"] = Int(screenSize.width)
        nextContext["screenHeight"] = Int(screenSize.height)
        return nextContext
    }
}
