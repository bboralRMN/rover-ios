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
        
        let dataStore = DataStore(accountToken: "giberish")
        rover.register(HTTPService.self, store: dataStore)
        
        let localStorage = MockStorage()
        let customerStore = CustomerStore(localStorage: localStorage)
        rover.register(Customer.self, store: customerStore)
        
        let httpFactory = rover.resolve(HTTPService.self)!
        XCTAssertEqual(httpFactory.authHeaders.count, 2)
        
        let customer = rover.resolve(Customer.self)!
        XCTAssertNil(customer.customerID)
        
        rover.setCustomerID("giberish")
        
        let nextHTTPService = rover.resolve(HTTPService.self)!
        XCTAssertEqual(nextHTTPService.authHeaders.count, 3)
        
        let nextCustomer = rover.resolve(Customer.self)!
        XCTAssertEqual(nextCustomer.customerID, "giberish")
    }
    
    func testUpdateCustomer() {
        let rover = Rover()
        
        let uploadService = MockUploadService()
        let eventsManager = EventsManager(uploadService: uploadService, flushAt: 1)
        let eventsStore = EventsStore { resolver, dispatcher in
            return EventsStore(eventsManager: eventsManager)
        }
        rover.register(EventsManager.self, store: eventsStore)
        
        let update = CustomerUpdate.setFirstName(value: "Marie")
        rover.updateCustomer([update])
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        
        let event = uploadService.firstEvent!
        XCTAssertEqual(event.name, "Customer Update")
        
        let updates = event.attributes!["updates"] as! [[String: Any]]
        let serialized = updates.first!
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "firstName")
        XCTAssertEqual(serialized["value"] as! String, "Marie")
    }
    
    func testGetCustomer() {
        let rover = Rover()
        
        let localStorage = MockStorage(customerID: "giberish")
        let customerStore = CustomerStore(localStorage: localStorage)
        rover.register(Customer.self, store: customerStore)
        
        let customer = rover.getCustomer()
        XCTAssertEqual(customer?.customerID, "giberish")
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
