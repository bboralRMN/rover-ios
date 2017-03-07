//
//  DeviceContextPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import RoverLogger

public struct DeviceContextPlugin {
    
    var systemInfo: SystemInfo
    
    public init() {
        self.init(systemInfo: nil)
    }
    
    init(systemInfo: SystemInfo? = nil) {
        self.systemInfo = systemInfo ?? UIDevice.current
    }
}

extension DeviceContextPlugin: Plugin { }

extension DeviceContextPlugin: ContextProvider {
    
    func deviceModel() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let size = MemoryLayout<CChar>.size
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: size) {
                String(cString: UnsafePointer<CChar>($0))
            }
        }
        if let model = String(validatingUTF8: modelCode) {
            return model
        }
        return nil
    }
    
    public func captureContext(_ context: Context) -> Context {
        var nextContext = context
        
        nextContext["deviceManufacturer"] = "Apple"
        nextContext["osName"] = systemInfo.systemName
        nextContext["osVersion"] = systemInfo.systemVersion
        
        if let deviceModel = self.deviceModel() {
            nextContext["deviceModel"] = deviceModel
        } else {
            logger.warn("Failed to obtain device model")
        }
        
        return nextContext
    }
}

// MARK: SystemInfo

protocol SystemInfo {
    
    var systemName: String { get }
    
    var systemVersion: String { get }
}

extension UIDevice: SystemInfo { }
