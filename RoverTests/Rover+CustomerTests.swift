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

    func testSetCustomerIDUpatesCustomer() {
        let rover = Rover()
        
        let httpFactory = HTTPServiceFactory(accountToken: "giberish")
        try! rover.register(HTTPService.self, factory: httpFactory)
        
        let localStorage = MockStorage()
        let factory = CustomerFactory(localStorage: localStorage)
        
        try! rover.register(Customer.self, factory: factory)
        
        let initialState = rover.resolve(Customer.self)!
        XCTAssertNil(initialState.customerID)
        
        rover.setCustomerID("giberish")
        
        let nextState = rover.resolve(Customer.self)!
        XCTAssertEqual(nextState.customerID, "giberish")
    }
    
    func testSetCustomerIDAddsAuthHeader() {
        let rover = Rover()
        
        let httpFactory = HTTPServiceFactory(accountToken: "giberish")
        try! rover.register(HTTPService.self, factory: httpFactory)
        
        let localStorage = MockStorage()
        let customerFactory = CustomerFactory(localStorage: localStorage)
        try! rover.register(Customer.self, factory: customerFactory)
        
        let initialState = rover.resolve(HTTPService.self)!
        XCTAssertEqual(initialState.authHeaders.count, 2)
        
        rover.setCustomerID("giberish")
        
        let nextState = rover.resolve(HTTPService.self)!
        XCTAssertEqual(nextState.authHeaders.count, 3)
    }
    
    func testUpdateCustomer() {
        let rover = Rover()
        
        let httpFactory = HTTPServiceFactory(accountToken: "giberish")
        try! rover.register(HTTPService.self, factory: httpFactory)
        
        let eventsFactory = EventsServiceFactory()
        try! rover.register(EventsService.self, factory: eventsFactory)
        
        let update = CustomerUpdate.setFirstName(value: "Marie")
        rover.updateCustomer([update])
        
        let eventsService = rover.resolve(EventsService.self)!
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        
        let event = eventsService.eventQueue.events[0]
        XCTAssertEqual(event.name, "Customer Update")
        
        let updates = event.attributes!["updates"] as! [[String: Any]]
        XCTAssertEqual(updates[0]["action"] as! String, "set")
        XCTAssertEqual(updates[0]["key"] as! String, "firstName")
        XCTAssertEqual(updates[0]["value"] as! String, "Marie")
    }
    
    func testGetCustomer() {
        let rover = Rover()
        
        let httpFactory = HTTPServiceFactory(accountToken: "giberish")
        try! rover.register(HTTPService.self, factory: httpFactory)
        
        let localStorage = MockStorage(customerID: "giberish")
        let factory = CustomerFactory(localStorage: localStorage)
        try! rover.register(Customer.self, factory: factory)
        
        let customer = rover.getCustomer()!
        XCTAssertEqual(customer.customerID, "giberish")
    }
}

fileprivate class MockStorage: LocalStorage {
    
    var customerID: String?
    
    init(customerID: String? = nil) {
        self.customerID = customerID
    }
    
    func string(forKey defaultName: String) -> String? {
        return customerID
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        customerID = value as? String
    }
}

fileprivate class MockUploadService: TrackEventsService {
    
    var firstEvent: TrackEventsMutation.Event?
    
    fileprivate func trackEventsTask(operation: TrackEventsMutation,
                                     authHeaders: [AuthHeader]?,
                                     completionHandler: ((TrackEventsResult) -> Void)?) -> HTTPTask {

        firstEvent = operation.events.first
        
        return MockTask {
            completionHandler?(TrackEventsResult.success)
        }
    }
}

fileprivate class MockTask: HTTPTask {
    
    var block: (() -> Void)?
    
    init(block: (() -> Void)? = nil) {
        self.block = block
    }
    
    func cancel() { }
    
    func resume() {
        block?()
    }
}
