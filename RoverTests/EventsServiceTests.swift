//
//  EventsServiceTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

import RoverData

@testable import Rover

class EventsServiceTests: XCTestCase {
    
    func testEventsAreAddedToQueue() {
        let uploadService = MockUploadService()
        let eventsService = EventsService(uploadService: uploadService,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        eventsService.trackEvent(name: "Test", attributes: nil, authHeaders: nil)
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsService.eventQueue.count, 1)
        
        let batch = eventsService.eventQueue.nextBatch(minSize: 1)!
        XCTAssertEqual(batch.count, 1)
        XCTAssertEqual(batch.first?.name, "Test")
    }
    
    func testEventsAreFlushedAutomatically() {
        let uploadService = MockUploadService()
        let eventsService = EventsService(uploadService: uploadService,
                                          flushAt: 1,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        eventsService.trackEvent(name: "Test", attributes: nil, authHeaders: nil)
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsService.eventQueue.count, 0)
    }
    
    func testEventsCanBeFlushedManually() {
        let uploadService = MockUploadService()
        let eventsService = EventsService(uploadService: uploadService,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        for _ in 1...50 {
            eventsService.trackEvent(name: "Test", attributes: nil, authHeaders: nil)
        }
        
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsService.eventQueue.count, 50)
        
        eventsService.flushEvents()
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsService.eventQueue.count, 0)
    }
    
    func testCaputuresCurrentUploadTask() {
        let uploadService = MockUploadService(delay: 100)
        let eventsService = EventsService(uploadService: uploadService,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        eventsService.trackEvent(name: "Test", attributes: nil, authHeaders: nil)
        eventsService.flushEvents()
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertNotNil(eventsService.uploadTask)
    }
    
    func testResetsCurrentUploadTask() {
        let uploadService = MockUploadService()
        let eventsService = EventsService(uploadService: uploadService,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        eventsService.trackEvent(name: "Test", attributes: nil, authHeaders: nil)
        eventsService.flushEvents()
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertNil(eventsService.uploadTask)
    }
    
    func testWontSendUntilFlushAt() {
        let uploadService = MockUploadService(delay: 100)
        let eventsService = EventsService(uploadService: uploadService,
                                          flushAt: 2,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        eventsService.trackEvent(name: "Test", attributes: nil, authHeaders: nil)
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertNil(eventsService.uploadTask)
    }
    
    func testRetriesUnsuccessfulUploads() {
        let result = TrackEventsResult.error(error: nil, shouldRetry: true)
        let uploadService = MockUploadService(result: result)
        let eventsService = EventsService(uploadService: uploadService,
                                          flushAt: 1,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        eventsService.trackEvent(name: "Test", attributes: nil, authHeaders: nil)
        eventsService.flushEvents()
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsService.eventQueue.count, 1)
    }
    
    func testDispatchesEvents() {
        let uploadService = MockUploadService()
        let eventsService = EventsService(uploadService: uploadService,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max)
        
        let e = expectation(description: "Event manager dispatches didTrackEvent")
        NotificationCenter.default.addObserver(forName: Notification.Name.didTrackEvent, object: eventsService, queue: nil) { notification in
            e.fulfill()
        }
        
        eventsService.trackEvent(name: "Test", attributes: nil, authHeaders: nil)
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testFlushesEventsOnEnteringBackground() {
        let uploadService = MockUploadService()
        let application = MockApplication()
        let notificationCenter = MockNotificationCenter()
        let eventsService = EventsService(uploadService: uploadService,
                                          contextProviders: nil,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max,
                                          application: application,
                                          notificationCenter: notificationCenter)
        
        eventsService.trackEvent(name: "Test", attributes: nil, authHeaders: nil)
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsService.eventQueue.count, 1)
        
        notificationCenter.callBlock(name: Notification.Name.UIApplicationDidEnterBackground.rawValue)
        XCTAssert(application.beginWasCalled)
        
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsService.eventQueue.count, 0)
    }
    
    func testEndsBackgroundTaskAfterSending() {
        let uploadService = MockUploadService()
        let application = MockApplication()
        let notificationCenter = MockNotificationCenter()
        let eventsService = EventsService(uploadService: uploadService,
                                          contextProviders: nil,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max,
                                          application: application,
                                          notificationCenter: notificationCenter)
        
        eventsService.trackEvent(name: "Test", attributes: nil, authHeaders: nil)
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        
        notificationCenter.callBlock(name: Notification.Name.UIApplicationDidEnterBackground.rawValue)
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        
        XCTAssertTrue(application.endWasCalled)
    }
    
    func testEndsBackgroundTasksWhenLessThanMinBatchSize() {
        let uploadService = MockUploadService()
        let application = MockApplication()
        let eventsService = EventsService(uploadService: uploadService,
                                          contextProviders: nil,
                                          flushAt: Int.max,
                                          flushInterval: 0.0,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max,
                                          application: application,
                                          notificationCenter: nil)
        
        eventsService.backgroundTask = 1
        eventsService.trackEvent(name: "Test", attributes: nil, authHeaders: nil)
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertTrue(application.endWasCalled)
    }
    
    func testFlushesOverTimeWhenApplicationActive() {
        let uploadService = MockUploadService()
        let notificationCenter = MockNotificationCenter()
        let eventsService = EventsService(uploadService: uploadService,
                                          contextProviders: nil,
                                          flushAt: Int.max,
                                          flushInterval: 0.1,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max,
                                          application: nil,
                                          notificationCenter: notificationCenter)
        
        eventsService.trackEvent(name: "Test", attributes: nil, authHeaders: nil)
        eventsService.serialQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(eventsService.eventQueue.count, 1)
        
        XCTAssertNil(eventsService.timer)
        notificationCenter.callBlock(name: Notification.Name.UIApplicationDidBecomeActive.rawValue)
        XCTAssertNotNil(eventsService.timer)
        
        let e = expectation(description: "Events are flushed")
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            eventsService.serialQueue.waitUntilAllOperationsAreFinished()
            XCTAssertEqual(eventsService.eventQueue.count, 0)
            e.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testCancelsFlushTimerWhenResigningActive() {
        let uploadService = MockUploadService()
        let notificationCenter = MockNotificationCenter()
        let eventsService = EventsService(uploadService: uploadService,
                                          contextProviders: nil,
                                          flushAt: Int.max,
                                          flushInterval: 0.1,
                                          maxBatchSize: Int.max,
                                          maxQueueSize: Int.max,
                                          application: nil,
                                          notificationCenter: notificationCenter)
        
        XCTAssertNil(eventsService.timer)
        
        notificationCenter.callBlock(name: Notification.Name.UIApplicationDidBecomeActive.rawValue)
        XCTAssertNotNil(eventsService.timer)
        
        notificationCenter.callBlock(name: Notification.Name.UIApplicationWillResignActive.rawValue)
        XCTAssertNil(eventsService.timer)
    }
    
    func testReassign() {
        let uploadService = MockUploadService()
        let eventsService = EventsService(uploadService: uploadService)
        let _ = eventsService
    }
}

// MARK: MockUploadService

fileprivate class MockUploadService: TrackEventsService {
    
    var result: TrackEventsResult
    
    var delay: Int
    
    init(result: TrackEventsResult = TrackEventsResult.success, delay: Int = 0) {
        self.result = result
        self.delay = delay
    }
    
    func trackEventsTask(operation: TrackEventsMutation,
                         authHeaders: [AuthHeader]?,
                         completionHandler: ((TrackEventsResult) -> Void)?) -> HTTPTask {
        
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
