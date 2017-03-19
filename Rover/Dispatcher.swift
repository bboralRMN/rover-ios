//
//  Dispatcher.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-17.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

protocol Dispatcher {
    
    func dispatch(action: Action)
}
