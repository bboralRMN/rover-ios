//
//  ServiceStore.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-22.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

struct ServiceStore {
    
    let factory: AnyServiceFactory
    
    let currentState: Service?
    
    let hasChanged: Bool
}
