//
//  HTTPPluginTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

import RoverData

class HTTPPluginTests: XCTestCase {
    
    func testNoOpReduce() {
        let state = HTTPFactory()
        XCTAssertEqual(state.authorizers.count, 0)
        
        let action = MockAction()
        let resolver = MockResolver()
        
        let nextState = HTTPPlugin.reduce(state: state, action: action, resolver: resolver)
        XCTAssertEqual(nextState.authorizers.count, 0)
    }
    
    func testAddAuthorizer() {
        let state = HTTPFactory()
        XCTAssertEqual(state.authorizers.count, 0)
        
        let authorizer = MockAuthorizer()
        let action = AddAuthorizerAction(authorizer: authorizer)
        let resolver = MockResolver()
        
        let nextState = HTTPPlugin.reduce(state: state, action: action, resolver: resolver)
        XCTAssertEqual(nextState.authorizers.count, 1)
    }
}

fileprivate struct MockAuthorizer: Authorizer {
    
    fileprivate func authorize(_ request: URLRequest) -> URLRequest {
        return request
    }
}

fileprivate struct MockAction: Action {

}

fileprivate struct MockResolver: Resolver {
    
    func resolve<T : Plugin>(_ pluginType: T.Type, name: String?) -> T.State? {
        return nil
    }
}
