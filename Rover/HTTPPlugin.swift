//
//  HTTPPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-01.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverData

protocol Plugin: class {
    
    associatedtype State
    
    var state: State { get }
    
    func register(dispatcher: Any)
    
    func reduce(state: State, action: String)
}

class HTTPPlugin: Plugin {
    
    typealias State = HTTPFactory
    
    var state: State {
        return HTTPFactory()
    }
    
    func register(dispatcher: Any) {
        
    }
    
    func reduce(state: State, action: String) {
        
    }
}
