//
//  HTTPServiceFactoryTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

import RoverData

class HTTPServiceFactoryTests: XCTestCase {
    
    func testRegister() {
        let uuid = UUID()
        let deviceIdentifier = MockDeviceIdentifier(uuid: uuid)
        let factory = HTTPServiceFactory(accountToken: "giberish", deviceIdentifier: deviceIdentifier)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)
        
        let authHeaders = initialState.authHeaders
        XCTAssertEqual(authHeaders.count, 2)
        XCTAssertEqual(authHeaders[0].headerField, "x-rover-account-token")
        XCTAssertEqual(authHeaders[0].value, "giberish")
        XCTAssertEqual(authHeaders[1].headerField, "x-rover-device-id")
        XCTAssertEqual(authHeaders[1].value, uuid.uuidString)
    }
    
    func testConfigureHTTPService() {
        let baseURL = URL(string: "http://example.com")!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let authHeader = AuthHeader(headerField: "foo", value: "bar")
        
        let uuid = UUID()
        let deviceIdentifier = MockDeviceIdentifier(uuid: uuid)
        let factory = HTTPServiceFactory(accountToken: "giberish", baseURL: baseURL, session: session, path: "/foo", authHeaders: [authHeader], deviceIdentifier: deviceIdentifier)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)
        
        XCTAssertEqual(initialState.baseURL, baseURL)
        XCTAssertEqual(initialState.path, "/foo")
        
        XCTAssertTrue(initialState.session === session)
        
        let authHeaders = initialState.authHeaders
        XCTAssertEqual(authHeaders.count, 3)
        XCTAssertEqual(authHeaders[0].headerField, "foo")
        XCTAssertEqual(authHeaders[0].value, "bar")
        XCTAssertEqual(authHeaders[1].headerField, "x-rover-account-token")
        XCTAssertEqual(authHeaders[1].value, "giberish")
        XCTAssertEqual(authHeaders[2].headerField, "x-rover-device-id")
        XCTAssertEqual(authHeaders[2].value, uuid.uuidString)
    }
    
    func testRegisterWithoutDeviceIdentifier() {
        let deviceIdentifier = MockDeviceIdentifier(uuid: nil)
        let factory = HTTPServiceFactory(accountToken: "giberish", deviceIdentifier: deviceIdentifier)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        
        do {
            let _ = try factory.register(resolver: resolver, dispatcher: dispatcher)
            XCTFail()
        } catch {
            switch error {
            case ServiceRegistrationError.unexpectedCondition:
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testNoOpAction() {
        let uuid = UUID()
        let deviceIdentifier = MockDeviceIdentifier(uuid: uuid)
        let factory = HTTPServiceFactory(accountToken: "giberish", deviceIdentifier: deviceIdentifier)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)
        
        let nextState = factory.reduce(state: initialState, action: MockAction(), resolver: MockResolver())
        XCTAssert(factory.areEqual(a: initialState, b: nextState))
    }
    
    func testAddAuthorizer() {
        let uuid = UUID()
        let deviceIdentifier = MockDeviceIdentifier(uuid: uuid)
        let factory = HTTPServiceFactory(accountToken: "giberish", deviceIdentifier: deviceIdentifier)
        
        let resolver = MockResolver()
        let dispatcher = MockDispatcher()
        let initialState = try! factory.register(resolver: resolver, dispatcher: dispatcher)
        
        XCTAssertEqual(initialState.authHeaders.count, 2)
        
        let authHeader = AuthHeader(headerField: "foo", value: "bar")
        let action = AddAuthHeaderAction(authHeader: authHeader)
        let nextState = factory.reduce(state: initialState, action: action, resolver: resolver)
        
        XCTAssertEqual(nextState.authHeaders.count, 3)
        XCTAssertEqual(nextState.authHeaders[2].headerField, "foo")
        XCTAssertEqual(nextState.authHeaders[2].value, "bar")
    }
}

fileprivate struct MockAction: Action { }

fileprivate struct MockResolver: Resolver {
    
    let serviceMap = ServiceMap()
}

fileprivate struct MockDispatcher: Dispatcher {
    
    func dispatch(action: Action) { }
}

fileprivate struct MockDeviceIdentifier: DeviceIdentifier {
    
    let uuid: UUID?
        
    init(uuid: UUID?) {
        self.uuid = uuid
    }
    
    var identifierForVendor: UUID? {
        return uuid
    }
}
