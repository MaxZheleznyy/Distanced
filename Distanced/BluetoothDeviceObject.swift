//
//    BluetoothDeviceObject.swift
//    Distanced
//
//    Created by Maxim Zheleznyy on 4/1/20.
//    Copyright © 2020 Maxim Zheleznyy. All rights reserved.
//

import Foundation
import CoreLocation

struct BluetoothDeviceObject: Hashable {
    let identifier: String
    let uuid: UUID
    let majorValue: CLBeaconMajorValue
    let minorValue: CLBeaconMinorValue
    let emojiName: String
    var beacon: CLBeacon
    
    var uniquNameHash: Int {
        get {
            return (identifier + String(majorValue) + String(minorValue)).hashValue
        }
    }
    
    private let emojiArray = ["✌", "😂", "😝", "😁", "😱", "👉", "🙌", "🍻", "🔥", "🌈", "☀", "🎈", "🌹", "💄", "🎀", "⚽", "🎾", "🏁", "😡", "👿", "🐻", "🐶", "🐬", "🐟", "🍀", "👀", "🚗", "🍎", "💝", "💙", "👌", "❤", "😍", "😉", "😓", "😳", "💪", "💩", "🍸", "🔑", "💖", "🌟", "🎉", "🌺", "🎶", "👠", "🏈", "⚾", "🏆", "👽", "💀", "🐵", "🐮", "🐩", "🐎", "💣", "👃", "👂", "🍓", "💘", "💜", "👊", "💋", "😘", "😜", "😵", "🙏", "👋", "🚽", "💃", "💎", "🚀", "🌙", "🎁", "⛄", "🌊", "⛵", "🏀", "🎱", "💰", "👶", "👸", "🐰", "🐷", "🐍", "🐫", "🔫", "👄", "🚲", "🍉", "💛", "💚"]
    
    init(identifier: String, uuid: UUID, majorValue: Int, minorValue: Int, beacon: CLBeacon) {
        self.identifier = identifier
        self.uuid = uuid
        self.majorValue = CLBeaconMajorValue(majorValue)
        self.minorValue = CLBeaconMinorValue(minorValue)
        self.beacon = beacon
        self.emojiName = emojiArray.randomElement() ?? "🐶"
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
    
    static func == (lhs: BluetoothDeviceObject, rhs: BluetoothDeviceObject) -> Bool {
        return lhs.uniquNameHash == rhs.uniquNameHash
    }
}
