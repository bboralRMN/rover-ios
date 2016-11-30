//
//  AsynchronousOperation.swift
//  Rover
//
//  Created by Sean Rucker on 2016-11-25.
//  Copyright © 2016 Rover Labs Inc. All rights reserved.
//

import Foundation

public class AsynchronousOperation: Operation {
    
    override public var isAsynchronous: Bool {
        return true
    }
    
    private var _isExecuting = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override public var isExecuting: Bool {
        return _isExecuting
    }
    
    private var _isFinished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override public var isFinished: Bool {
        return _isFinished
    }
    
    override public func start() {
        if isCancelled {
            _isFinished = true
            return
        }
        
        _isExecuting = true
        execute()
    }
    
    func execute() {
        
    }
    
    func finish() {
        _isExecuting = false
        _isFinished = true
    }
}
