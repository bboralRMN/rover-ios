//
//  EventManagerTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

import RoverData

@testable import Rover

class EventManagerTests: XCTestCase {
    
    func testEventsAreAddedToQueue() {
        let eventManager = EventManager(
            flushAt: Int.max,
            flushInterval: 0.0,
            maxQueueSize: Int.max,
            maxBatchSize: Int.max,
            apiClient: MockAPIClient(),
            contextProvider: nil
        )
        
        eventManager.trackEvent(name: "Test")
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventManager.eventQueue.count, 1)
        
        let batch = eventManager.eventQueue.nextBatch(minSize: 1)
        XCTAssertEqual(batch.count, 1)
        XCTAssertEqual(batch.first?.name, "Test")
    }
    
    func testEventsAreFlushedAutomatically() {
        let eventManager = EventManager(
            flushAt: 1,
            flushInterval: 0.0,
            maxQueueSize: Int.max,
            maxBatchSize: Int.max,
            apiClient: MockAPIClient(),
            contextProvider: nil
        )
        
        eventManager.trackEvent(name: "Test")
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventManager.eventQueue.count, 0)
    }
    
    func testEventsCanBeFlushedManually() {
        let eventManager = EventManager(
            flushAt: Int.max,
            flushInterval: 0.0,
            maxQueueSize: Int.max,
            maxBatchSize: Int.max,
            apiClient: MockAPIClient(),
            contextProvider: nil
        )
        
        for _ in 1...50 {
            eventManager.trackEvent(name: "Test")
        }
        
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventManager.eventQueue.count, 50)
        
        eventManager.flushEvents()
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventManager.eventQueue.count, 0)
    }
    
    func testCaputuresCurrentUploadTask() {
        let eventManager = EventManager(
            flushAt: Int.max,
            flushInterval: 0.0,
            maxQueueSize: Int.max,
            maxBatchSize: Int.max,
            apiClient: MockAPIClient(delay: 100),
            contextProvider: nil
        )
        
        eventManager.trackEvent(name: "Test")
        eventManager.flushEvents()
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertNotNil(eventManager.uploadTask)
    }
    
    func testResetsCurrentUploadTask() {
        let eventManager = EventManager(
            flushAt: Int.max,
            flushInterval: 0.0,
            maxQueueSize: Int.max,
            maxBatchSize: Int.max,
            apiClient: MockAPIClient(),
            contextProvider: nil
        )
        
        eventManager.trackEvent(name: "Test")
        eventManager.flushEvents()
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertNil(eventManager.uploadTask)
    }
    
    func testWontSendUntilFlushAt() {
        let eventManager = EventManager(
            flushAt: 2,
            flushInterval: 0.0,
            maxQueueSize: Int.max,
            maxBatchSize: Int.max,
            apiClient: MockAPIClient(delay: 100),
            contextProvider: nil
        )
        
        eventManager.trackEvent(name: "Test")
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertNil(eventManager.uploadTask)
    }
    
    func testRetriesUnsuccessfulUploads() {
        let result = TrackEventsResult.error(error: nil, shouldRetry: true)
        let apiClient = MockAPIClient(result: result)
        let eventManager = EventManager(
            flushAt: 1,
            flushInterval: 0.0,
            maxQueueSize: Int.max,
            maxBatchSize: Int.max,
            apiClient: apiClient,
            contextProvider: nil
        )
        
        eventManager.trackEvent(name: "Test")
        eventManager.flushEvents()
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventManager.eventQueue.count, 1)
    }
    
    func testDispatchesEvents() {
        let eventManager = EventManager(
            flushAt: Int.max,
            flushInterval: 0.0,
            maxQueueSize: Int.max,
            maxBatchSize: Int.max,
            apiClient: MockAPIClient(),
            contextProvider: nil
        )
        
        let e = expectation(description: "Event manager dispatches didTrackEvent")
        NotificationCenter.default.addObserver(forName: Notification.Name.didTrackEvent, object: eventManager, queue: nil) { notification in
            e.fulfill()
        }
        
        eventManager.trackEvent(name: "Test")
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testFlushesEventsOnEnteringBackground() {
        let application = MockApplication()
        let notificationCenter = MockNotificationCenter()
        
        let eventManager = EventManager(
            flushAt: Int.max,
            flushInterval: 0.0,
            maxQueueSize: Int.max,
            maxBatchSize: Int.max,
            apiClient: MockAPIClient(),
            contextProvider: nil,
            application: application,
            notificationCenter: notificationCenter
        )
        
        eventManager.trackEvent(name: "Test")
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventManager.eventQueue.count, 1)
        
        notificationCenter.callBlock(name: Notification.Name.UIApplicationDidEnterBackground.rawValue)
        XCTAssert(application.beginWasCalled)
        
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventManager.eventQueue.count, 0)
    }
    
    func testEndsBackgroundTaskAfterSending() {
        let application = MockApplication()
        let notificationCenter = MockNotificationCenter()
        
        let eventManager = EventManager(
            flushAt: Int.max,
            flushInterval: 0.0,
            maxQueueSize: Int.max,
            maxBatchSize: Int.max,
            apiClient: MockAPIClient(),
            contextProvider: nil,
            application: application,
            notificationCenter: notificationCenter
        )
        
        eventManager.trackEvent(name: "Test")
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        
        notificationCenter.callBlock(name: Notification.Name.UIApplicationDidEnterBackground.rawValue)
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        
        XCTAssertTrue(application.endWasCalled)
    }
    
    func testEndsBackgroundTasksWhenLessThanMinBatchSize() {
        let application = MockApplication()
        
        let eventManager = EventManager(
            flushAt: Int.max,
            flushInterval: 0.0,
            maxQueueSize: Int.max,
            maxBatchSize: Int.max,
            apiClient: MockAPIClient(),
            contextProvider: nil,
            application: application
        )
        
        eventManager.backgroundTask = 1
        eventManager.trackEvent(name: "Test")
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertTrue(application.endWasCalled)
    }
    
    func testFlushesOverTimeWhenApplicationActive() {
        let notificationCenter = MockNotificationCenter()
        
        let eventManager = EventManager(
            flushAt: Int.max,
            flushInterval: 0.1,
            maxQueueSize: Int.max,
            maxBatchSize: Int.max,
            apiClient: MockAPIClient(),
            contextProvider: nil,
            notificationCenter: notificationCenter
        )
        
        eventManager.trackEvent(name: "Test")
        eventManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventManager.eventQueue.count, 1)
        
        XCTAssertNil(eventManager.timer)
        notificationCenter.callBlock(name: Notification.Name.UIApplicationDidBecomeActive.rawValue)
        XCTAssertNotNil(eventManager.timer)
        
        let e = expectation(description: "Events are flushed")
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            eventManager.serialQueue.waitUntilAllOperationsAreFinished()
            XCTAssertEqual(eventManager.eventQueue.count, 0)
            e.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testCancelsFlushTimerWhenResigningActive() {
        let notificationCenter = MockNotificationCenter()
        
        let eventManager = EventManager(
            flushAt: Int.max,
            flushInterval: 0.1,
            maxQueueSize: Int.max,
            maxBatchSize: Int.max,
            apiClient: MockAPIClient(),
            contextProvider: nil,
            notificationCenter: notificationCenter
        )
        
        XCTAssertNil(eventManager.timer)
        
        notificationCenter.callBlock(name: Notification.Name.UIApplicationDidBecomeActive.rawValue)
        XCTAssertNotNil(eventManager.timer)
        
        notificationCenter.callBlock(name: Notification.Name.UIApplicationWillResignActive.rawValue)
        XCTAssertNil(eventManager.timer)
    }
}

// MARK: MockAPIClient

class MockAPIClient: EventsAPIClient {
    
    var result: TrackEventsResult
    
    var delay: Int
    
    init(result: TrackEventsResult = TrackEventsResult.success, delay: Int = 0) {
        self.result = result
        self.delay = delay
    }
    
    func trackEventsTask(events: [EventInputType], completionHandler: ((TrackEventsResult) -> Void)?) -> HTTPTask {
        return MockTask(delay: delay) {
            completionHandler?(self.result)
        }
    }
}

// MARK: MockTask

fileprivate class MockTask: HTTPTask {
    
    var delay: Int
    
    var block: (() -> Void)?
    
    var isCancelled = false
    
    init(delay: Int = 0, block: (() -> Void)? = nil) {
        self.delay = delay
        self.block = block
    }
    
    func cancel() {
        isCancelled = true
    }
    
    func resume() {
        if delay > 0 {
            let deadline: DispatchTime = .now() + .milliseconds(delay)
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                if !self.isCancelled {
                    self.block?()
                }
            }
        } else {
            block?()
        }
    }
}

// MARK: MockApplication

class MockApplication: ApplicationType {
    
    var beginWasCalled = false
    var endWasCalled = false
    
    func beginBackgroundTask(expirationHandler handler: (() -> Void)?) -> UIBackgroundTaskIdentifier {
        beginWasCalled = true
        return UIBackgroundTaskIdentifier(arc4random_uniform(10000))
    }
    
    func endBackgroundTask(_ identifier: UIBackgroundTaskIdentifier) {
        endWasCalled = true
    }
}

// MARK: MockNotificationCenter

class MockNotificationCenter: NotificationCenterType {
    
    typealias Block = (Notification) -> Void
    
    var blocks = [String: Block]()
    
    func addObserver(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
        guard let name = name else {
            return NSObject()
        }
        
        blocks[name.rawValue] = block
        return NSObject()
    }
    
    func callBlock(name: String) {
        guard let block = blocks[name] else {
            return
        }
        
        let note = Notification(name: Notification.Name(rawValue: "Test"))
        block(note)
    }
}
