//
//  CustomerUpdateTests.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-12.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import XCTest

@testable import Rover

class CustomerUpdateTests: XCTestCase {
    
    func testSetFirstName() {
        let update = CustomerUpdate.setFirstName(value: "Marie")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "firstName")
        XCTAssertEqual(serialized["value"] as! String, "Marie")
    }
    
    func testClearFirstName() {
        let update = CustomerUpdate.clearFirstName
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "firstName")
    }
    
    func testSetLastName() {
        let update = CustomerUpdate.setLastName(value: "Avgeropoulos")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "lastName")
        XCTAssertEqual(serialized["value"] as! String, "Avgeropoulos")
    }
    
    func testClearLastName() {
        let update = CustomerUpdate.clearLastName
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "lastName")
    }
    
    func testSetEmail() {
        let update = CustomerUpdate.setEmail(value: "marie.avgeropoulos@example.com")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "email")
        XCTAssertEqual(serialized["value"] as! String, "marie.avgeropoulos@example.com")
    }
    
    func testClearEmail() {
        let update = CustomerUpdate.clearEmail
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "email")
    }
    
    func testSetGender() {
        let update = CustomerUpdate.setGender(value: .female)
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "gender")
        XCTAssertEqual(serialized["value"] as! String, CustomerUpdate.Gender.female.rawValue)
    }
    
    func testClearGender() {
        let update = CustomerUpdate.clearGender
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "gender")
    }
    
    func testSetAge() {
        let update = CustomerUpdate.setAge(value: 30)
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "age")
        XCTAssertEqual(serialized["value"] as! Int, 30)
    }
    
    func testClearAge() {
        let update = CustomerUpdate.clearAge
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "age")
    }
    
    func testSetPhoneNumber() {
        let update = CustomerUpdate.setPhoneNumber(value: "555-555-5555")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "phoneNumber")
        XCTAssertEqual(serialized["value"] as! String, "555-555-5555")
    }
    
    func testClearPhoneNumber() {
        let update = CustomerUpdate.clearPhoneNumber
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "phoneNumber")
    }
    
    func testSetTags() {
        let update = CustomerUpdate.setTags(value: ["actress", "model", "musician"])
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "tags")
        XCTAssertEqual(serialized["value"] as! [String], ["actress", "model", "musician"])
    }
    
    func testClearTags() {
        let update = CustomerUpdate.clearTags
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "tags")
    }
    
    func testAddTag() {
        let update = CustomerUpdate.addTag(value: "actress")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "add")
        XCTAssertEqual(serialized["key"] as! String, "tags")
        XCTAssertEqual(serialized["value"] as! String, "actress")
    }
    
    func testRemoveTag() {
        let update = CustomerUpdate.removeTag(value: "model")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "remove")
        XCTAssertEqual(serialized["key"] as! String, "tags")
        XCTAssertEqual(serialized["value"] as! String, "model")
    }
    
    func testSetCustomValue() {
        let update = CustomerUpdate.setCustomValue(key: "height", value: 1.65)
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "set")
        XCTAssertEqual(serialized["key"] as! String, "height")
        XCTAssertEqual(serialized["value"] as! Double, 1.65)
    }
    
    func testClearCustomValue() {
        let update = CustomerUpdate.clearCustomValue(key: "foo")
        let serialized = update.serialized
        
        XCTAssertEqual(serialized["action"] as! String, "clear")
        XCTAssertEqual(serialized["key"] as! String, "foo")
    }
}
