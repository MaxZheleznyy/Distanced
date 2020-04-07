//
//    BeaconDeviceObject.swift
//    Distanced
//
//    Created by Maxim Zheleznyy on 4/1/20.
//    Copyright © 2020 Maxim Zheleznyy. All rights reserved.
//

import Foundation
import CoreLocation

struct BeaconDeviceObject: Hashable {
    let uuid: UUID
    let majorValue: CLBeaconMajorValue
    let minorValue: CLBeaconMinorValue
    
    var beacon: CLBeacon
    var emojiName: String?
    
    private var uniquNameHash: Int {
        get {
            return (String(majorValue) + String(minorValue)).hashValue
        }
    }
    
    init(beacon: CLBeacon) {
        self.beacon = beacon
        
        if #available(iOS 13.0, *) {
            self.uuid = beacon.uuid
        } else {
            self.uuid = beacon.proximityUUID
        }
        
        self.majorValue = CLBeaconMajorValue(truncating: beacon.major)
        self.minorValue = CLBeaconMinorValue(truncating: beacon.minor)
    }
    
    func locationString() -> String {
        let proximity = nameForProximity(beacon.proximity)
        let accuracy = String(format: "%.2f", beacon.accuracy)
        
        var location = "Location: \(proximity)"
        if beacon.proximity != .unknown {
          location += " (approx. \(accuracy)m)"
        }
        
        return location
    }
    
    func nameForProximity(_ proximity: CLProximity) -> String {
        switch proximity {
        case .unknown:
            return "Unknown"
        case .immediate:
            return "Immediate"
        case .near:
            return "Near"
        case .far:
            return "Far"
            
        @unknown default:
            fatalError()
        }
    }
    
    static func == (lhs: BeaconDeviceObject, rhs: BeaconDeviceObject) -> Bool {
        return lhs.uniquNameHash == rhs.uniquNameHash
    }
}
