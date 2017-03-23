//
//  RoverTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-07.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData
import RoverLogger

@testable import Rover

class RoverTests: XCTestCase {
    
    func testAssemble() {
        UserDefaults.standard.set("80000516109", forKey: "io.rover.userID")
        
        Rover.assemble(accountToken: "giberish")
        
        let httpService = Rover.shared.resolve(HTTPService.self)!
        let authHeaders = httpService.authHeaders
        XCTAssertEqual(authHeaders.count, 3)
        XCTAssertEqual(authHeaders[0].headerField, "x-rover-account-token")
        XCTAssertEqual(authHeaders[0].value, "giberish")
        XCTAssertEqual(authHeaders[1].headerField, "x-rover-device-id")
        XCTAssertEqual(authHeaders[1].value, UIDevice.current.identifierForVendor!.uuidString)
        XCTAssertEqual(authHeaders[2].headerField, "x-rover-user-id")
        XCTAssertEqual(authHeaders[2].value, "80000516109")
        
        let eventsService = Rover.shared.resolve(EventsService.self)!
        XCTAssertEqual(eventsService.uploadService as! HTTPService, httpService)
        XCTAssertEqual(eventsService.contextProviders.count, 8)
        
        let user = Rover.shared.resolve(UserService.self)!
        XCTAssertEqual(user.userID, "80000516109")
    }
    
    func testSavesRegistrationToMap() {
        let rover = Rover()
        XCTAssertEqual(rover.serviceMap.count, 0)
        
        try! rover.register(String.self, factory: StringFactory())
        XCTAssertEqual(rover.serviceMap.count, 1)
        
        let key = ServiceKey(serviceType: String.self, name: nil)
        XCTAssertEqual(rover.serviceMap[key]?.currentState as! String, "giberish")
    }
    
    func testSavesRegistrationToArray() {
        let rover = Rover()
        XCTAssertEqual(rover.registeredServices.count, 0)
        
        try! rover.register(String.self, factory: StringFactory())
        XCTAssertEqual(rover.registeredServices.count, 1)
        
        let key = ServiceKey(serviceType: String.self, name: nil)
        XCTAssertEqual(rover.registeredServices.first!, key)
    }
    
    func testCantRegisterSameServiceTwice() {
        let rover = Rover()
        XCTAssertEqual(rover.serviceMap.count, 0)
        
        try! rover.register(String.self, factory: StringFactory())
        XCTAssertEqual(rover.serviceMap.count, 1)
        
        do {
            try rover.register(String.self, factory: StringFactory())
            XCTFail()
        } catch {
            switch error {
            case ServiceRegistrationError.alreadyRegistered:
                break
            default:
                XCTFail()
            }
        }
        
        XCTAssertEqual(rover.serviceMap.count, 1)
        
        try! rover.register(String.self, factory: StringFactory(), name: "foo")
        XCTAssertEqual(rover.serviceMap.count, 2)
        
        try! rover.register(Int.self, factory: IntFactory())
        XCTAssertEqual(rover.serviceMap.count, 3)
    }
    
    func testReturnsNilForMissingService() {
        let rover = Rover()
        let state = rover.resolve(String.self)
        XCTAssertNil(state)
    }
    
    func testReturnsStateForRegisteredService() {
        let rover = Rover()
        
        try! rover.register(String.self, factory: StringFactory())
        
        let state = rover.resolve(String.self)
        XCTAssertEqual(state, "giberish")
    }
    
    func testReducesEachRegisteredPlugin() {
        let rover = Rover()
        
        let stringFactory = StringFactory()
        try! rover.register(String.self, factory: stringFactory)
        
        let intFactory = IntFactory()
        try! rover.register(Int.self, factory: intFactory)
        
        XCTAssertFalse(stringFactory.reduceWasCalled)
        XCTAssertFalse(intFactory.reduceWasCalled)
        
        let action = MockAction()
        rover.dispatch(action: action)
        
        XCTAssertTrue(stringFactory.reduceWasCalled)
        XCTAssertTrue(intFactory.reduceWasCalled)
        
        let string = rover.resolve(String.self)
        let int = rover.resolve(Int.self)
        XCTAssertEqual(string, "hgiberis")
        XCTAssertEqual(int, 2)
    }
}

fileprivate struct MockAction: Action { }

// MARK: StringFactory

fileprivate final class StringFactory {
    
    var reduceWasCalled = false
}

extension StringFactory: ServiceFactory {
    
    func register(resolver: Resolver, dispatcher: Dispatcher) throws -> String {
        return "giberish"
    }
    
    func reduce(state: String, action: Action, resolver: Resolver) -> String {
        reduceWasCalled = true
        
        var nextState = state
        let character = nextState.remove(at: nextState.index(before: nextState.endIndex))
        return "\(character)\(nextState)"
    }
    
    func areEqual(a: String?, b: String?) -> Bool {
        return a == b
    }
}

// MARK: IntFactory

fileprivate final class IntFactory {
    
    var reduceWasCalled = false
}

extension IntFactory: ServiceFactory {
    
    func register(resolver: Resolver, dispatcher: Dispatcher) throws -> Int {
        return 1
    }
    
    func reduce(state: Int, action: Action, resolver: Resolver) -> Int {
        reduceWasCalled = true
        return state + 1
    }
    
    func areEqual(a: Int?, b: Int?) -> Bool {
        return a == b
    }
}
