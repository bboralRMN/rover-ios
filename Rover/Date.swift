//
//  Date.swift
//  Rover
//
//  Created by Sean Rucker on 2016-11-24.
//  Copyright © 2016 Rover Labs Inc. All rights reserved.
//

import Foundation

extension Date {
    
    var iso8601FormattedString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.string(from: self)
    }
}
