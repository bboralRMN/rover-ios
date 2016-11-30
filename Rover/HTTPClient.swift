//
//  HTTPClient.swift
//  Rover
//
//  Created by Sean Rucker on 2016-11-24.
//  Copyright © 2016 Rover Labs Inc. All rights reserved.
//

import Foundation

class HTTPClient: HTTPUploadClient {

    func upload(url: URL, body: JSON, completionHandler: @escaping (Bool, Bool) -> Void) -> URLSessionUploadTask {
        
        let config = URLSessionConfiguration.default
        
        let token = "foobar"
        
        config.httpAdditionalHeaders = [
            "Accept-Endcoding": "gzip",
            "Content-Encoding": "gzip",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let payload = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        // TODO: Gzip the payload
        let gzippedPayload = payload
        
        let task = session.uploadTask(with: request, from: gzippedPayload) { data, response, error in
            guard error == nil else {
                print("Error uploading requst \(error)")
                return
            }
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            switch statusCode {
            case let n where n < 300:
                completionHandler(true, false)
            case let n where n < 400:
                print("Server responded with unexpected HTTP code \(statusCode)")
                completionHandler(false, true)
            case let n where n < 500:
                print("Server rejected payload with HTTP code \(statusCode)")
                completionHandler(false, false)
            default:
                print("Server error with HTTP code \(statusCode)")
                completionHandler(false, true)
            }
        }
        
        task.resume()
        return task
    }
}

protocol HTTPClientConfiguration {
    
    var apiEndpoint: String { get }
    
    var accountToken: String { get }
}

protocol HTTPUploadClient {
    
    func upload(url: URL, body: JSON, completionHandler: @escaping (Bool, Bool) -> Void) -> URLSessionUploadTask
}
