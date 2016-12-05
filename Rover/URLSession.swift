//
//  URLSession.swift
//  Rover
//
//  Created by Sean Rucker on 2016-11-30.
//  Copyright © 2016 Rover Labs Inc. All rights reserved.
//

import Foundation

extension URLSession: HTTPSession {

    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionUploadTask {
        return (uploadTask(with: request, from: bodyData, completionHandler: completionHandler) as URLSessionUploadTask) as HTTPSessionUploadTask
    }
}
