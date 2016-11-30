//
//  Serializeable.swift
//  Rover
//
//  Created by Sean Rucker on 2016-11-25.
//  Copyright © 2016 Rover Labs Inc. All rights reserved.
//

import Foundation

protocol Serializeable {
    
    func serialize() -> JSON
}

extension Serializeable {
    
    func addAttribute(json: inout JSON, key: String, value: Any?) {
        guard let value = value else {
            return
        }
        
        var attributes = json["attributes"] as? JSON
        
        if attributes == nil {
            attributes = JSON()
        }
        
        attributes?[key] = value
        json["attributes"] = attributes
    }
    
    func addRelationship(json: inout JSON, key: String, type: String, id: String?) {
        guard let id = id else {
            return
        }
        
        var relationships = json["relationships"] as? JSON
        
        if relationships == nil {
            relationships = JSON()
        }
        
        relationships?[key] = [
            "data": [
                "type": type,
                "id": id
            ]
        ]
        
        json["relationships"] = relationships
    }
}
