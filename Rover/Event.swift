//
//  Event.swift
//  Rover
//
//  Created by Sean Rucker on 2016-11-24.
//  Copyright © 2016 Rover Labs Inc. All rights reserved.
//

import Foundation

struct Event: Serializeable {
    
    let eventId: UUID
    
    let timestamp: Date
    
    let name: String
    
    let attributes: JSON?
    
    init(name: String, attributes: JSON? = nil, eventId: UUID = UUID(), timestamp: Date = Date()) {
        self.name = name
        self.attributes = attributes
        self.eventId = eventId
        self.timestamp = timestamp
    }
    
    func serialize() -> JSON {
        var payload: JSON = [
            "eventId": eventId.uuidString,
            "name": name,
            "timestamp": timestamp.iso8601FormattedString
        ]
        
        if let attributes = attributes {
            payload["attributes"] = coerceJSONObject(attributes)
        }
        
        return payload
    }
    
    func coerceJSONObject(_ obj: Any) -> Any {
        // TODO: Ensure all attributes can be sent as a payload
        return obj
    }
}



//static id SEGCoerceJSONObject(id obj) {
//    // if the object is a NSString, NSNumber or NSNull
//    // then we're good
//    if ([obj isKindOfClass:[NSString class]] ||
//        [obj isKindOfClass:[NSNumber class]] ||
//        [obj isKindOfClass:[NSNull class]]) {
//        return obj;
//    }
//
//    if ([obj isKindOfClass:[NSArray class]]) {
//        NSMutableArray *array = [NSMutableArray array];
//        for (id i in obj)
//            [array addObject:SEGCoerceJSONObject(i)];
//        return array;
//    }
//
//    if ([obj isKindOfClass:[NSDictionary class]]) {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        for (NSString *key in obj) {
//            if (![key isKindOfClass:[NSString class]])
//                SEGLog(@"warning: dictionary keys should be strings. got: %@. coercing " @"to: %@", [key class], [key description]);
//            dict[key.description] = SEGCoerceJSONObject(obj[key]);
//        }
//        return dict;
//    }
//
//    if ([obj isKindOfClass:[NSDate class]])
//        return iso8601FormattedString(obj);
//
//    if ([obj isKindOfClass:[NSURL class]])
//        return [obj absoluteString];
//
//    // default to sending the object's description
//    SEGLog(@"warning: dictionary values should be valid json types. got: %@. " @"coercing to: %@", [obj class], [obj description]);
//    return [obj description];
//}
