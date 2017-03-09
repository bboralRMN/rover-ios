//
//  Container.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-09.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

protocol Container {
    
    func register<T : Plugin>(_ pluginType: T.Type, initialState: T.State)
}
