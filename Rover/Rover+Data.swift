//
//  Rover+Data.swift
//  Rover
//
//  Created by Sean Rucker on 2017-03-10.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation

import RoverData
import RoverLogger

extension Rover {
    
    func addAuthHeader(_ authHeader: AuthHeader) {
        let action = AddAuthHeaderAction(authHeader: authHeader)
        dispatch(action: action)
    }
    
    func sync() {
        guard let service = resolve(HTTPService.self) else {
            logger.error("Attempted to sync before HTTPService was registered")
            return
        }
        
        let task = service.syncTask { syncResult in
            let action = SyncCompleteAction(syncResult: syncResult)
            self.dispatch(action: action)
        }
        task.resume()
    }
}
