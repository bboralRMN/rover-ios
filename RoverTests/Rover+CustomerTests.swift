//
//  Rover+CustomerTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest
import RoverData

@testable import Rover

class Rover_CustomerTests: XCTestCase {

    func testSetCustomerID() {
        let rover = Rover()
        let storage = MockStorage()
        var customer = Customer(storage: storage)
        rover.register(CustomerPlugin.self, initialState: customer)
        
        customer = rover.resolve(CustomerPlugin.self)!
        XCTAssertNil(customer.customerID)
        
        rover.setCustomerID("giberish")
        customer = rover.resolve(CustomerPlugin.self)!
        XCTAssertEqual(customer.customerID, "giberish")
    }
    
    func testUpdateCustomer() {
        let rover = Rover()
        let httpFactory = HTTPFactory()
        rover.register(HTTPPlugin.self, initialState: httpFactory)
        
        let eventsManager = EventsManager(taskFactory: httpFactory)
        rover.register(EventsPlugin.self, initialState: eventsManager)
        XCTAssertEqual(eventsManager.eventQueue.count, 0)
        
        let update = CustomerUpdate.setFirstName(value: "Marie")
        rover.updateCustomer([update])
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 1)
    }
}

fileprivate struct MockStorage: CustomerIDStorage {
    
    var customerID: String?
    
    init(customerID: String? = nil) {
        self.customerID = customerID
    }
}
