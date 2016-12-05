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
        let eventManager = EventManager(uploadClient: MockUploadClient())
        
        for _ in 1...5 {
            eventManager.trackEvent(name: "test")
        }
        
        XCTAssertEqual(eventManager.serialQueue.operationCount, 5)
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        
        XCTAssertEqual(eventManager.events.count, 5)
    }
    
    func testFlushEventsAtSize() {
        let e = expectation(description: "First batch size equals sendAt")
        
        let eventManager = EventManager(uploadClient: MockUploadClient())
        
        NotificationCenter.default.addObserver(forName: .didFinishUpload, object: eventManager, queue: nil) { notification in
            
            let events = notification.userInfo?["events"] as! [Event]
            XCTAssertEqual(events.count, eventManager.flushAt)
            e.fulfill()
        }
        
        for _ in 1...eventManager.flushAt {
            eventManager.trackEvent(name: "test")
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testMaxBatchSize() {
        let e = expectation(description: "Batch size never exceeds maxBatchSize")
        
        let uploadClient = MockUploadClient()
        uploadClient.success = false
        uploadClient.retry = true
        
        let eventManager = EventManager(flushAt: 1, maxBatchSize: 10, uploadClient: uploadClient)
        var batchCount = 0
        
        NotificationCenter.default.addObserver(forName: .didFinishUpload, object: eventManager, queue: nil) { notification in
            batchCount += 1
            
            let events = notification.userInfo?["events"] as! [Event]
            XCTAssertLessThanOrEqual(events.count, eventManager.maxBatchSize)
            
            if batchCount < 3 * eventManager.maxBatchSize {
                eventManager.trackEvent(name: "test")
            } else {
                e.fulfill()
            }
        }
        
        eventManager.trackEvent(name: "test")

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testMaxQueueSize() {
        let e = expectation(description: "Events array never exceeds maxTotalEvents")
        
        let uploadClient = MockUploadClient()
        uploadClient.success = false
        uploadClient.retry = true
        
        let eventManager = EventManager(flushAt: 1, maxQueueSize: 10, uploadClient: uploadClient)
        var batchCount = 0
        
        NotificationCenter.default.addObserver(forName: .didFinishUpload, object: eventManager, queue: nil) { notification in
            batchCount += 1
            
            XCTAssertLessThanOrEqual(eventManager.events.count, eventManager.maxQueueSize)
            
            if batchCount < 3 * eventManager.maxQueueSize {
                eventManager.trackEvent(name: "test")
            } else {
                e.fulfill()
            }
        }
        
        eventManager.trackEvent(name: "test")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}

fileprivate class MockUploadClient: HTTPUploadClient {
    
    var success: Bool = true
    var retry: Bool = false
    
    fileprivate func upload(url: URL, body: JSON, completionHandler: @escaping (Bool, Bool) -> Void) -> HTTPSessionUploadTask {
        completionHandler(self.success, self.retry)
        return URLSessionUploadTask()
    }
}
