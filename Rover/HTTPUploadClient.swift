//
//  HTTPUploadClient.swift
//  Rover
//
//  Created by Sean Rucker on 2016-12-01.
//  Copyright © 2016 Rover Labs Inc. All rights reserved.
//

import Foundation

protocol HTTPUploadClient {
    
    func upload(url: URL, body: JSON, completionHandler: @escaping (Bool, Bool) -> Void) -> HTTPSessionUploadTask
}
