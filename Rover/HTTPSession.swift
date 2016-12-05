//
//  HTTPSession.swift
//  Rover
//
//  Created by Sean Rucker on 2016-11-30.
//  Copyright © 2016 Rover Labs Inc. All rights reserved.
//

import Foundation

protocol HTTPSession {
    
    func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionUploadTask
    
    func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask
}
