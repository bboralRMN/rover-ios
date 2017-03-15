//
//  EventsManagerTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

import RoverData

@testable import Rover

class EventsManagerTests: XCTestCase {
    
    func testEventsAreAddedToQueue() {
        let taskFactory = MockTaskFactory()
        let eventsManager = EventsManager(taskFactory: taskFactory,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        eventsManager.trackEvent(name: "Test")
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 1)
        
        let batch = eventsManager.eventQueue.nextBatch(minSize: 1)
        XCTAssertEqual(batch.count, 1)
        XCTAssertEqual(batch.first?.name, "Test")
    }
    
    func testEventsAreFlushedAutomatically() {
        let taskFactory = MockTaskFactory()
        let eventsManager = EventsManager(taskFactory: taskFactory,
                                          flushAt: 1,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        eventsManager.trackEvent(name: "Test")
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 0)
    }
    
    func testEventsCanBeFlushedManually() {
        let taskFactory = MockTaskFactory()
        let eventsManager = EventsManager(taskFactory: taskFactory,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        for _ in 1...50 {
            eventsManager.trackEvent(name: "Test")
        }
        
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 50)
        
        eventsManager.flushEvents()
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 0)
    }
    
    func testCaputuresCurrentUploadTask() {
        let taskFactory = MockTaskFactory(delay: 100)
        let eventsManager = EventsManager(taskFactory: taskFactory,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        eventsManager.trackEvent(name: "Test")
        eventsManager.flushEvents()
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertNotNil(eventsManager.uploadTask)
    }
    
    func testResetsCurrentUploadTask() {
        let taskFactory = MockTaskFactory()
        let eventsManager = EventsManager(taskFactory: taskFactory,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        eventsManager.trackEvent(name: "Test")
        eventsManager.flushEvents()
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertNil(eventsManager.uploadTask)
    }
    
    func testWontSendUntilFlushAt() {
        let taskFactory = MockTaskFactory(delay: 100)
        let eventsManager = EventsManager(taskFactory: taskFactory,
                                          flushAt: 2,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        eventsManager.trackEvent(name: "Test")
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertNil(eventsManager.uploadTask)
    }
    
    func testRetriesUnsuccessfulUploads() {
        let result = TrackEventsResult.error(error: nil, shouldRetry: true)
        let taskFactory = MockTaskFactory(result: result)
        let eventsManager = EventsManager(taskFactory: taskFactory,
                                          flushAt: 1,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        eventsManager.trackEvent(name: "Test")
        eventsManager.flushEvents()
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 1)
    }
    
    func testDispatchesEvents() {
        let taskFactory = MockTaskFactory()
        let eventsManager = EventsManager(taskFactory: taskFactory,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        let e = expectation(description: "Event manager dispatches didTrackEvent")
        NotificationCenter.default.addObserver(forName: Notification.Name.didTrackEvent, object: eventsManager, queue: nil) { notification in
            e.fulfill()
        }
        
        eventsManager.trackEvent(name: "Test")
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testFlushesEventsOnEnteringBackground() {
        let taskFactory = MockTaskFactory()
        let application = MockApplication()
        let notificationCenter = MockNotificationCenter()
        let eventsManager = EventsManager(taskFactory: taskFactory,
                                          contextProviders: nil,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max,
                                          application: application,
                                          notificationCenter: notificationCenter)
        
        eventsManager.trackEvent(name: "Test")
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 1)
        
        notificationCenter.callBlock(name: Notification.Name.UIApplicationDidEnterBackground.rawValue)
        XCTAssert(application.beginWasCalled)
        
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 0)
    }
    
    func testEndsBackgroundTaskAfterSending() {
        let taskFactory = MockTaskFactory()
        let application = MockApplication()
        let notificationCenter = MockNotificationCenter()
        let eventsManager = EventsManager(taskFactory: taskFactory,
                                          contextProviders: nil,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max,
                                          application: application,
                                          notificationCenter: notificationCenter)
        
        eventsManager.trackEvent(name: "Test")
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        
        notificationCenter.callBlock(name: Notification.Name.UIApplicationDidEnterBackground.rawValue)
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        
        XCTAssertTrue(application.endWasCalled)
    }
    
    func testEndsBackgroundTasksWhenLessThanMinBatchSize() {
        let taskFactory = MockTaskFactory()
        let application = MockApplication()
        let eventsManager = EventsManager(taskFactory: taskFactory,
                                          contextProviders: nil,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max,
                                          application: application,
                                          notificationCenter: nil)
        
        eventsManager.backgroundTask = 1
        eventsManager.trackEvent(name: "Test")
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertTrue(application.endWasCalled)
    }
    
    func testFlushesOverTimeWhenApplicationActive() {
        let taskFactory = MockTaskFactory()
        let notificationCenter = MockNotificationCenter()
        let eventsManager = EventsManager(taskFactory: taskFactory,
                                          contextProviders: nil,
                                          flushAt: Int.max,
                                          flushInterval: 0.1,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max,
                                          application: nil,
                                          notificationCenter: notificationCenter)
        
        eventsManager.trackEvent(name: "Test")
        eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsManager.eventQueue.count, 1)
        
        XCTAssertNil(eventsManager.timer)
        notificationCenter.callBlock(name: Notification.Name.UIApplicationDidBecomeActive.rawValue)
        XCTAssertNotNil(eventsManager.timer)
        
        let e = expectation(description: "Events are flushed")
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            eventsManager.serialQueue.waitUntilAllOperationsAreFinished()
            XCTAssertEqual(eventsManager.eventQueue.count, 0)
            e.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testCancelsFlushTimerWhenResigningActive() {
        let taskFactory = MockTaskFactory()
        let notificationCenter = MockNotificationCenter()
        let eventsManager = EventsManager(taskFactory: taskFactory,
                                          contextProviders: nil,
                                          flushAt: Int.max,
                                          flushInterval: 0.1,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max,
                                          application: nil,
                                          notificationCenter: notificationCenter)
        
        XCTAssertNil(eventsManager.timer)
        
        notificationCenter.callBlock(name: Notification.Name.UIApplicationDidBecomeActive.rawValue)
        XCTAssertNotNil(eventsManager.timer)
        
        notificationCenter.callBlock(name: Notification.Name.UIApplicationWillResignActive.rawValue)
        XCTAssertNil(eventsManager.timer)
    }
    
    func testReassign() {
        let taskFactory = MockTaskFactory()
        let eventsManager = EventsManager(taskFactory: taskFactory)
        let _ = eventsManager
    }
}

// MARK: MockTaskFactory

class MockTaskFactory: EventsTaskFactory {
    
    var result: TrackEventsResult
    
    var delay: Int
    
    init(result: TrackEventsResult = TrackEventsResult.success, delay: Int = 0) {
        self.result = result
        self.delay = delay
    }
    
    func trackEventsTask(events: [EventInput], completionHandler: ((TrackEventsResult) -> Void)?) -> HTTPTask {
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
