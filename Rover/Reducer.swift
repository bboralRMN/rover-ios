//
//  Reducer.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-09.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

protocol Action { }

protocol Reducer {
    
    func reduce(action: Action)
}
