//
//  ContextProvider.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverData

public protocol ContextProvider {
    
    func captureContext(_ context: Context) -> Context
}
