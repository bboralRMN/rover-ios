//
//  UserUpdate.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-12.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

public enum UserUpdate {
    
    public enum Gender: String {
        case male, female
    }
    
    case setFirstName(value: String), clearFirstName
    case setLastName(value: String), clearLastName
    case setGender(value: Gender), clearGender
    case setAge(value: Int), clearAge
    case setEmail(value: String), clearEmail
    case setPhoneNumber(value: String), clearPhoneNumber
    case setTags(value: [String]), clearTags
    case addTag(value: String), removeTag(value: String)
    case setCustomValue(key: String, value: Any), clearCustomValue(key: String)
    
    var action: String {
        switch self {
        case .setFirstName, .setLastName, .setGender, .setAge, .setEmail, .setPhoneNumber, .setTags, .setCustomValue:
            return "set"
        case .clearFirstName, .clearLastName, .clearGender, .clearEmail, .clearAge, .clearPhoneNumber, .clearTags, .clearCustomValue:
            return "clear"
        case .addTag:
            return "add"
        case .removeTag:
            return "remove"
        }
    }
    
    var key: String {
        switch self {
        case .setFirstName, .clearFirstName:
            return "firstName"
        case .setLastName, .clearLastName:
            return "lastName"
        case .setGender, .clearGender:
            return "gender"
        case .setAge, .clearAge:
            return "age"
        case .setEmail, .clearEmail:
            return "email"
        case .setPhoneNumber, .clearPhoneNumber:
            return "phoneNumber"
        case .setTags, .clearTags, .addTag, .removeTag:
            return "tags"
        case .setCustomValue(let key, _), .clearCustomValue(let key):
            return key
        }
    }
    
    var serialized: [String: Any] {
        switch self {
        case let .setFirstName(value), let .setLastName(value), let .setEmail(value), let .setPhoneNumber(value), let .addTag(value), let .removeTag(value):
            return ["action": action, "key": key, "value": value]
        case let .setGender(gender):
            return ["action": action, "key": key, "value": gender.rawValue]
        case let .setAge(value):
            return ["action": action, "key": key, "value": value]
        case .clearFirstName, .clearLastName, .clearGender, .clearAge, .clearEmail, .clearPhoneNumber, .clearTags:
            return ["action": action, "key": key]
        case let .setTags(tags):
            return ["action": action, "key": key, "value": tags]
        case let .setCustomValue(key, value):
            return ["action": action, "key": key, "value": value]
        case let .clearCustomValue(key):
            return ["action": action, "key": key]
        }
    }
}
