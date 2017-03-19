//
//  ServiceKey.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-18.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

struct ServiceKey {
    
    let serviceType: Service.Type
    
    let name: String?
}

extension ServiceKey: CustomStringConvertible {
    
    var description: String {
        if let name = name {
            return "\(serviceType) (\(name))"
        }
        
        return "\(serviceType)"
    }
}

extension ServiceKey: Hashable {
    
    var hashValue: Int {
        return String(describing: serviceType).hashValue ^ (name?.hashValue ?? 0)
    }
}

func == (lhs: ServiceKey, rhs: ServiceKey) -> Bool {
    return lhs.serviceType == rhs.serviceType && lhs.name == rhs.name
}
