//
//  EventManagerTests.swift
//  RoverTests
//
//  Created by Sean Rucker on 2016-11-21.
//  Copyright © 2016 Rover Labs Inc. All rights reserved.
//

import XCTest
@testable import Rover

class EventManagerTests: XCTestCase {
    
    func testAddingEventsSize() {
        var config = TestConfiguration()
        config.sendAt = Int.max
        
        let eventManager = EventManager(configuration: config)
        
        for _ in 1...5 {
            eventManager.trackEvent(name: "test")
        }
        
        XCTAssertEqual(eventManager.serialQueue.operationCount, 5)
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        
        XCTAssertEqual(eventManager.events.count, 5)
    }
    
    func testSendAtSize() {
        let e = expectation(description: "First batch size equals sendAt")
        
        let config = TestConfiguration()
        let eventManager = EventManager(configuration: config)
        
        NotificationCenter.default.addObserver(forName: .didFinishUpload, object: eventManager, queue: nil) { notification in
            
            let events = notification.userInfo?["events"] as! [Event]
            XCTAssertEqual(events.count, config.sendAt)
            e.fulfill()
        }
        
        for _ in 1...config.sendAt {
            eventManager.trackEvent(name: "test")
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testMaxBatchSize() {
        let e = expectation(description: "Batch size never exceeds maxBatchSize")
        
        let uploadClient = MockUploadClient()
        uploadClient.success = false
        uploadClient.retry = true
        
        var config = TestConfiguration()
        config.sendAt = 1
        config.maxBatchSize = 10
        config.uploadClient = uploadClient
        
        let eventManager = EventManager(configuration: config)
        var batchCount = 0
        
        NotificationCenter.default.addObserver(forName: .didFinishUpload, object: eventManager, queue: nil) { notification in
            batchCount += 1
            
            let events = notification.userInfo?["events"] as! [Event]
            XCTAssertLessThanOrEqual(events.count, config.maxBatchSize)
            
            if batchCount < 3 * config.maxBatchSize {
                eventManager.trackEvent(name: "test")
            } else {
                e.fulfill()
            }
        }
        
        eventManager.trackEvent(name: "test")

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testMaxTotalEvents() {
        let e = expectation(description: "Events array never exceeds maxTotalEvents")
        
        let uploadClient = MockUploadClient()
        uploadClient.success = false
        uploadClient.retry = true
        
        var config = TestConfiguration()
        config.sendAt = 1
        config.maxTotalEvents = 10
        config.uploadClient = uploadClient
        
        let eventManager = EventManager(configuration: config)
        var batchCount = 0
        
        NotificationCenter.default.addObserver(forName: .didFinishUpload, object: eventManager, queue: nil) { notification in
            batchCount += 1
            
            XCTAssertLessThanOrEqual(eventManager.events.count, config.maxTotalEvents)
            
            if batchCount < 3 * config.maxTotalEvents {
                eventManager.trackEvent(name: "test")
            } else {
                e.fulfill()
            }
        }
        
        eventManager.trackEvent(name: "test")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}

fileprivate struct TestConfiguration: EventManagerConfiguration {
    
    var sendAt: Int = 20
    
    var maxBatchSize: Int = 100
    
    var maxTotalEvents: Int = 1000
    
    var uploadURL: URL = URL(string: "http://example.com")!
    
    var uploadClient: HTTPUploadClient = MockUploadClient()
}

fileprivate class MockUploadClient: HTTPUploadClient {
    
    var success: Bool = true
    var retry: Bool = false
    
    fileprivate func upload(url: URL, body: JSON, completionHandler: @escaping (Bool, Bool) -> Void) -> URLSessionUploadTask {
        completionHandler(self.success, self.retry)
        return URLSessionUploadTask()
    }
}
