//
//  Rover.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-13.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

public class Rover {
    
    private static var _shared: Rover?
    
    public static var shared: Rover {
        guard let shared = _shared else {
            fatalError("Rover shared instance accessed before calling configure")
        }
        return shared
    }
    
    public static func configure(_ config: RoverConfiguration) {
        _shared = Rover()
    }
    
    private init() { }
}
