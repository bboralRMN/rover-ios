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
        XCTAssertEqual(rover.serviceMap.count, 0)
        
        let store = StringStore()
        rover.register(String.self, store: store)
        XCTAssertEqual(rover.serviceMap.count, 1)
        
        let key = ServiceKey(serviceType: String.self, name: nil)
        XCTAssertEqual(rover.serviceMap[key]?.currentState as! String, "giberish")
    }
    
    func testSavesRegistrationToArray() {
        let rover = Rover()
        XCTAssertEqual(rover.registeredServices.count, 0)
        
        let store = StringStore()
        rover.register(String.self, store: store)
        XCTAssertEqual(rover.registeredServices.count, 1)
        
        let key = ServiceKey(serviceType: String.self, name: nil)
        XCTAssertEqual(rover.registeredServices.first!, key)
    }
    
    func testCantRegisterSameServiceTwice() {
        let rover = Rover()
        XCTAssertEqual(rover.serviceMap.count, 0)
        
        let store = StringStore()
        rover.register(String.self, store: store)
        XCTAssertEqual(rover.serviceMap.count, 1)
        
        let anotherStore = StringStore()
        rover.register(String.self, store: anotherStore)
        XCTAssertEqual(rover.serviceMap.count, 1)
        
        rover.register(String.self, store: store, name: "foo")
        XCTAssertEqual(rover.serviceMap.count, 2)
        
        let differentStore = IntStore()
        rover.register(Int.self, store: differentStore)
        XCTAssertEqual(rover.serviceMap.count, 3)
    }
    
    func testReturnsNilForMissingService() {
        let rover = Rover()
        let state = rover.resolve(String.self)
        XCTAssertNil(state)
    }
    
    func testReturnsStateForRegisteredService() {
        let rover = Rover()
        
        let store = StringStore()
        rover.register(String.self, store: store)
        
        let state = rover.resolve(String.self)
        XCTAssertEqual(state, "giberish")
    }
    
    func testReducesEachRegisteredPlugin() {
        let rover = Rover()
        
        let stringStore = StringStore()
        rover.register(String.self, store: stringStore)
        
        let intStore = IntStore()
        rover.register(Int.self, store: intStore)
        
        XCTAssertFalse(stringStore.reduceWasCalled)
        XCTAssertFalse(intStore.reduceWasCalled)
        
        let action = MockAction()
        rover.dispatch(action: action)
        XCTAssertTrue(stringStore.reduceWasCalled)
        XCTAssertTrue(intStore.reduceWasCalled)
        
        let string = rover.resolve(String.self)
        let int = rover.resolve(Int.self)
        XCTAssertEqual(string, "hgiberis")
        XCTAssertEqual(int, 2)
    }
}

fileprivate struct MockAction: Action { }

// MARK: StringStore

fileprivate final class StringStore {
    
    var string = "giberish"
    
    var reduceWasCalled = false
}

extension StringStore: Store {
    
    var currentState: String? {
        return string
    }
    
    func register(resolver: Resolver, dispatcher: Dispatcher) -> StringStore {
        return self
    }
    
    func reduce(action: Action, resolver: Resolver) -> StringStore {
        let character = string.remove(at: string.index(before: string.endIndex))
        string = "\(character)\(string)"
        reduceWasCalled = true
        return self
    }
    
    func isChanged(by action: Action) -> Bool {
        return false
    }
}

// MARK: IntStore

fileprivate final class IntStore {
    
    var int = 1
    
    var reduceWasCalled = false
}

extension IntStore: Store {
    
    var currentState: Int? {
        return int
    }
    
    func register(resolver: Resolver, dispatcher: Dispatcher) -> IntStore {
        return self
    }
    
    func reduce(action: Action, resolver: Resolver) -> IntStore {
        int = int + 1
        reduceWasCalled = true
        return self
    }
    
    func isChanged(by action: Action) -> Bool {
        return false
    }
}
