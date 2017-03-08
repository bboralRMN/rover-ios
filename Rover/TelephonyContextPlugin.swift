//
//  TelephonyContextPlugin.swift
//  Rover
//
//  Created by Sean Rucker on 2017-02-16.
//  Copyright © 2017 Rover Labs Inc. All rights reserved.
//

import Foundation
import CoreTelephony
import RoverLogger

public struct TelephonyContextPlugin {
    
    var telephonyNetworkInfo: TelephonyNetworkInfoType
    
    var carrier: CarrierType?
    
    init(telephonyNetworkInfo: TelephonyNetworkInfoType? = nil, carrier: CarrierType? = nil) {
        switch (telephonyNetworkInfo, carrier) {
        case let (telephonyNetworkInfo?, carrier?):
            self.telephonyNetworkInfo = telephonyNetworkInfo
            self.carrier = carrier
        case (_, let carrier?):
            self.telephonyNetworkInfo = CTTelephonyNetworkInfo()
            self.carrier = carrier
        case (let telephonyNetworkInfo?, _):
            self.telephonyNetworkInfo = telephonyNetworkInfo
            self.carrier = CTTelephonyNetworkInfo().subscriberCellularProvider
        case (_, _):
            let telephonyNetworkInfo = CTTelephonyNetworkInfo()
            self.telephonyNetworkInfo = telephonyNetworkInfo
            self.carrier = telephonyNetworkInfo.subscriberCellularProvider as? CarrierType
        }
    }
    
    public init() {
        self.init(telephonyNetworkInfo: nil, carrier: nil)
    }
}

extension TelephonyContextPlugin: ContextProvider {
    
    var radio: String? {
        var radio = telephonyNetworkInfo.currentRadioAccessTechnology
        let prefix = "CTRadioAccessTechnology"
        if radio == nil {
            radio = "None"
        } else if radio!.hasPrefix(prefix) {
            radio = (radio! as NSString).substring(from: prefix.characters.count)
        }
        return radio
    }
    
    public func captureContext(_ context: Context) -> Context {
        var nextContext = context
        
        if let carrierName = carrier?.carrierName {
            nextContext["carrierName"] = carrierName
        } else {
            logger.warn("Could not obtain carrierName")
        }
        
        if let radio = self.radio {
            nextContext["radio"] = radio
        } else {
            logger.warn("Could not obtain radio")
        }
        
        return nextContext
    }
}

// MARK: TelephonyNetworkInfoType

protocol TelephonyNetworkInfoType {
    var currentRadioAccessTechnology: String? { get }
}

extension CTTelephonyNetworkInfo: TelephonyNetworkInfoType { }

// MARK: CarrierType

protocol CarrierType {
    var carrierName: String? { get }
}

extension CTCarrier: CarrierType { }
