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
    
    func testRegister() {
        let rover = Rover()
        XCTAssertEqual(rover.plugins.count, 0)
        
        rover.register(DeviceContextPlugin.self) { (resolver, prevResult) in
            return DeviceContextPlugin()
        }
        
        XCTAssertEqual(rover.plugins.count, 1)
        
        let firstKey = rover.plugins.first!.key
        
        typealias Factory = (Resolver, DeviceContextPlugin?) -> DeviceContextPlugin
        let constructedKey = PluginKey(factoryType: Factory.self, name: nil)
        
        XCTAssertEqual(firstKey, constructedKey)
    }
    
    func testResolveRegisteredPlugin() {
        let rover = Rover()
        
        rover.register(DeviceContextPlugin.self) { (resolver, prevResult) in
            return DeviceContextPlugin()
        }
        
        let plugin = rover.resolve(DeviceContextPlugin.self)!
        XCTAssertNotNil(plugin)
    }
    
    func testResolveMissingPlugin() {
        let rover = Rover()
        
        let plugin = rover.resolve(DeviceContextPlugin.self)
        XCTAssertNil(plugin)
    }
    
    func testResolveInvokesFactoryEachTime() {
        let rover = Rover()
        
        var factoryInvocationCount = 0
        rover.register(DeviceContextPlugin.self) { (resolver, prevResult) in
            factoryInvocationCount += 1
            return DeviceContextPlugin()
        }
        
        let _ = rover.resolve(DeviceContextPlugin.self)!
        let _ = rover.resolve(DeviceContextPlugin.self)!
        
        XCTAssertEqual(factoryInvocationCount, 2)
    }
    
    func testMultipleResolveRetainsPreviousValue() {
        
        struct MockPlugin: Plugin {
            var value: Int = 0
            var prevValues = [Int]()
        }
        
        let rover = Rover()
        
        rover.register(MockPlugin.self) { (resolver, prevResult) in
            if let prevResult = prevResult {
                let value = prevResult.prevValues.count + 1
                let prevValues = prevResult.prevValues + [prevResult.value]
                return MockPlugin(value: value, prevValues: prevValues)
            }
            
            return MockPlugin()
        }
        
        let result1 = rover.resolve(MockPlugin.self)!
        XCTAssertEqual(result1.value, 0)
        XCTAssertEqual(result1.prevValues.count, 0)
        
        let result2 = rover.resolve(MockPlugin.self)!
        XCTAssertEqual(result2.value, 1)
        XCTAssertEqual(result2.prevValues.count, 1)
        
        let result3 = rover.resolve(MockPlugin.self)!
        XCTAssertEqual(result3.value, 2)
        XCTAssertEqual(result3.prevValues.count, 2)
    }
    
    func testMultipleRegisterRetainsPreviousValue() {
        
        struct MockPlugin: Plugin {
            var value: Int = 0
            var prevValues = [Int]()
        }
        
        let rover = Rover()
        
        
        func factory(resolver: Resolver, prevResult: MockPlugin?) -> MockPlugin {
            if let prevResult = prevResult {
                let value = prevResult.prevValues.count + 1
                let prevValues = prevResult.prevValues + [prevResult.value]
                return MockPlugin(value: value, prevValues: prevValues)
            }
            
            return MockPlugin()
        }

        
        rover.register(MockPlugin.self, factory: factory)
        
        let result1 = rover.resolve(MockPlugin.self)!
        XCTAssertEqual(result1.value, 0)
        XCTAssertEqual(result1.prevValues.count, 0)
        
        rover.register(MockPlugin.self, factory: factory)
        
        let result2 = rover.resolve(MockPlugin.self)!
        XCTAssertEqual(result2.value, 1)
        XCTAssertEqual(result2.prevValues.count, 1)
    }
}
