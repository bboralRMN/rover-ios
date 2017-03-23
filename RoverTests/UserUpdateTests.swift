//
//  UserUpdateTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-12.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class UserUpdateTests: XCTestCase {
    
    func testSetFirstName() {
        let update = UserUpdate.setFirstName(value: "Marie")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "firstName")
        XCTAssertEqual(serialized["value"] as! String, "Marie")
    }
    
    func testClearFirstName() {
        let update = UserUpdate.clearFirstName
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "firstName")
    }
    
    func testSetLastName() {
        let update = UserUpdate.setLastName(value: "Avgeropoulos")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "lastName")
        XCTAssertEqual(serialized["value"] as! String, "Avgeropoulos")
    }
    
    func testClearLastName() {
        let update = UserUpdate.clearLastName
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "lastName")
    }
    
    func testSetEmail() {
        let update = UserUpdate.setEmail(value: "marie.avgeropoulos@example.com")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "email")
        XCTAssertEqual(serialized["value"] as! String, "marie.avgeropoulos@example.com")
    }
    
    func testClearEmail() {
        let update = UserUpdate.clearEmail
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "email")
    }
    
    func testSetGender() {
        let update = UserUpdate.setGender(value: .female)
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "gender")
        XCTAssertEqual(serialized["value"] as! String, UserUpdate.Gender.female.rawValue)
    }
    
    func testClearGender() {
        let update = UserUpdate.clearGender
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "gender")
    }
    
    func testSetAge() {
        let update = UserUpdate.setAge(value: 30)
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "age")
        XCTAssertEqual(serialized["value"] as! Int, 30)
    }
    
    func testClearAge() {
        let update = UserUpdate.clearAge
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "age")
    }
    
    func testSetPhoneNumber() {
        let update = UserUpdate.setPhoneNumber(value: "555-555-5555")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "phoneNumber")
        XCTAssertEqual(serialized["value"] as! String, "555-555-5555")
    }
    
    func testClearPhoneNumber() {
        let update = UserUpdate.clearPhoneNumber
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "phoneNumber")
    }
    
    func testSetTags() {
        let update = UserUpdate.setTags(value: ["actress", "model", "musician"])
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "tags")
        XCTAssertEqual(serialized["value"] as! [String], ["actress", "model", "musician"])
    }
    
    func testClearTags() {
        let update = UserUpdate.clearTags
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "tags")
    }
    
    func testAddTag() {
        let update = UserUpdate.addTag(value: "actress")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "add")
        XCTAssertEqual(serialized["key"] as! String, "tags")
        XCTAssertEqual(serialized["value"] as! String, "actress")
    }
    
    func testRemoveTag() {
        let update = UserUpdate.removeTag(value: "model")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "remove")
        XCTAssertEqual(serialized["key"] as! String, "tags")
        XCTAssertEqual(serialized["value"] as! String, "model")
    }
    
    func testSetCustomValue() {
        let update = UserUpdate.setCustomValue(key: "height", value: 1.65)
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "height")
        XCTAssertEqual(serialized["value"] as! Double, 1.65)
    }
    
    func testClearCustomValue() {
        let update = UserUpdate.clearCustomValue(key: "foo")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "foo")
    }
}
