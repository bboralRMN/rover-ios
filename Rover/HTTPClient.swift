//
//  HTTPClient.swift
//  Rover
//
//  Created by Sean Rucker on 2016-11-24.
//  Copyright © 2016 Rover Labs Inc. All rights reserved.
//

import Foundation

class HTTPClient: HTTPUploadClient {

    let session: HTTPSession
    
    init(session: HTTPSession? = nil) {
        self.session = session ?? URLSession(configuration: URLSessionConfiguration.default)
    }
    
    func upload(url: URL, body: JSON, completionHandler: @escaping (Bool, Bool) -> Void) -> HTTPSessionUploadTask {
        
        let token = "foobar"
        
        var request = URLRequest(url: url)
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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
