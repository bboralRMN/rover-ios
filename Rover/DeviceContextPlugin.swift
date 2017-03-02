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
    
    var device: DeviceType
    
    init(device: DeviceType? = nil) {
        self.device = device ?? UIDevice.current
    }
    
    public init() {
        self.init(device: nil)
    }
}

extension DeviceContextPlugin: Plugin {
    
    public var name: String {
        return "DeviceContextPlugin"
    }
    
    public func register(rover: Rover) {
        
    }
}

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
        nextContext["osName"] = device.systemName
        nextContext["osVersion"] = device.systemVersion
        
        if let deviceId = device.identifierForVendor?.uuidString {
            nextContext["deviceId"] = deviceId
        } else {
            logger.warn("Failed to obtain identifierForVendor")
        }
        
        if let deviceModel = self.deviceModel() {
            nextContext["deviceModel"] = deviceModel
        } else {
            logger.warn("Failed to obtain device model")
        }
        
        return nextContext
    }
}

// MARK: DeviceType

protocol DeviceType {
    
    var systemName: String { get }
    
    var systemVersion: String { get }
    
    var identifierForVendor: UUID? { get }
}

extension UIDevice: DeviceType { }
