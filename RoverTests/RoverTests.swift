//
//  RoverTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class RoverTests: XCTestCase {
    
    func testSavesRegistrationToMap() {
        let rover = Rover()
        XCTAssertEqual(rover.pluginMap.count, 0)
        
        rover.register(StringPlugin.self, initialState: "giberish")
        XCTAssertEqual(rover.pluginMap.count, 1)
        
        let key = PluginKey(pluginType: StringPlugin.self, name: nil)
        XCTAssertEqual(rover.pluginMap[key] as! String, "giberish")
    }
    
    func testSavesRegistrationToArray() {
        let rover = Rover()
        XCTAssertEqual(rover.registeredPlugins.count, 0)
        
        rover.register(StringPlugin.self, initialState: "giberish")
        XCTAssertEqual(rover.registeredPlugins.count, 1)
        
        let key = PluginKey(pluginType: StringPlugin.self, name: nil)
        XCTAssertEqual(rover.registeredPlugins.first!, key)
    }
    
    func testCantRegisterSamePluginTwice() {
        let rover = Rover()
        XCTAssertEqual(rover.pluginMap.count, 0)
        
        rover.register(StringPlugin.self, initialState: "giberish")
        XCTAssertEqual(rover.pluginMap.count, 1)
        
        rover.register(StringPlugin.self, initialState: "giberish")
        XCTAssertEqual(rover.pluginMap.count, 1)
        
        rover.register(IntPlugin.self, initialState: 1)
        XCTAssertEqual(rover.pluginMap.count, 2)
    }
    
    func testCantRegisterWithUnmetDependencies() {
        let rover = Rover()
        XCTAssertEqual(rover.pluginMap.count, 0)
        
        rover.register(IntPlugin.self, initialState: 1)
        XCTAssertEqual(rover.pluginMap.count, 0)
        
        rover.register(StringPlugin.self, initialState: "giberish")
        XCTAssertEqual(rover.pluginMap.count, 1)
        
        rover.register(IntPlugin.self, initialState: 1)
        XCTAssertEqual(rover.pluginMap.count, 2)
    }
    
    func testReturnsNilForMissingPlugin() {
        let rover = Rover()
        let state = rover.resolve(StringPlugin.self)
        XCTAssertNil(state)
    }
    
    func testReturnsStateForRegisteredPlugin() {
        let rover = Rover()
        rover.register(StringPlugin.self, initialState: "giberish")
        let state = rover.resolve(StringPlugin.self)
        XCTAssertEqual(state, "giberish")
    }
    
    func testReducesEachRegisteredPlugin() {
        let rover = Rover()
        rover.register(StringPlugin.self, initialState: "giberish")
        rover.register(IntPlugin.self, initialState: 1)
        XCTAssertFalse(StringPlugin.reduceWasCalled)
        XCTAssertFalse(IntPlugin.reduceWasCalled)
        
        let action = MockAction()
        rover.reduce(action: action)
        XCTAssertTrue(StringPlugin.reduceWasCalled)
        XCTAssertTrue(IntPlugin.reduceWasCalled)
        
        let string = rover.resolve(StringPlugin.self)
        let int = rover.resolve(IntPlugin.self)
        XCTAssertEqual(string, "hgiberis")
        XCTAssertEqual(int, 2)
    }
}

fileprivate struct StringPlugin: Plugin {
    
    static var reduceWasCalled = false
    
    typealias State = String
    
    static var dependencies: [AnyPlugin.Type] {
        return [AnyPlugin.Type]()
    }
    
    static func register(dispatcher: Any) {
        
    }
    
    static func reduce(state: String, action: Action, resolver: Resolver) -> String {
        reduceWasCalled = true
        var nextState = state
        let character = nextState.remove(at: state.index(before: state.endIndex))
        print("SEANTEST \(character)\(nextState)")
        return "\(character)\(nextState)"
    }
}

fileprivate struct IntPlugin: Plugin {
    
    static var reduceWasCalled = false
    
    typealias State = Int
    
    static var dependencies: [AnyPlugin.Type] {
        return [StringPlugin.self]
    }
    
    static func register(dispatcher: Any) {
        
    }
    
    static func reduce(state: Int, action: Action, resolver: Resolver) -> Int {
        reduceWasCalled = true
        return state + 1
    }
}

fileprivate struct MockAction: Action {
    
}
