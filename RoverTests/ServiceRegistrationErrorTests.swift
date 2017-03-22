//
//  ServiceRegistrationErrorTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-22.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData

@testable import Rover

class ServiceRegistrationErrorTests: XCTestCase {
    
    func testAlreadyRegisteredDescription() {
        let serviceKey = ServiceKey(serviceType: Customer.self, name: nil)
        let error = ServiceRegistrationError.alreadyRegistered(serviceKey: serviceKey)
        XCTAssertEqual(error.localizedDescription, "Customer has already been registered")
    }
    
    func testUnmetDependencyDescription() {
        let error = ServiceRegistrationError.unmetDependency(serviceType: Customer.self, dependencyType: HTTPService.self)
        XCTAssertEqual(error.localizedDescription, "Failed to register Customer due to unmet dependency HTTPService")
    }
    
    func testUnexpectedErrorDescription() {
        let description = "Lorem ipsum sit dolor amet..."
        let error = ServiceRegistrationError.unexpectedCondition(description: description)
        XCTAssertEqual(error.localizedDescription, description)
    }
}
