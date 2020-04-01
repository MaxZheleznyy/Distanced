//
//  BluetoothObject.swift
//  Distanced
//
//  Created by Maxim Zheleznyy on 4/1/20.
//  Copyright © 2020 Maxim Zheleznyy. All rights reserved.
//

import Foundation
import CoreLocation

struct BluetoothObjectConstant {
  static let nameKey = "name"
  static let uuidKey = "uuid"
  static let majorKey = "major"
  static let minorKey = "minor"
}

class BluetoothObject: NSObject, NSCoding {
  let name: String
  let uuid: UUID
  let majorValue: CLBeaconMajorValue
  let minorValue: CLBeaconMinorValue
  
  init(name: String, uuid: UUID, majorValue: Int, minorValue: Int) {
    self.name = name
    self.uuid = uuid
    self.majorValue = CLBeaconMajorValue(majorValue)
    self.minorValue = CLBeaconMinorValue(minorValue)
  }

  required init(coder aDecoder: NSCoder) {
    let aName = aDecoder.decodeObject(forKey: BluetoothObjectConstant.nameKey) as? String
    name = aName ?? ""
    
    let aUUID = aDecoder.decodeObject(forKey: BluetoothObjectConstant.uuidKey) as? UUID
    uuid = aUUID ?? UUID()
    
    majorValue = UInt16(aDecoder.decodeInteger(forKey: BluetoothObjectConstant.majorKey))
    minorValue = UInt16(aDecoder.decodeInteger(forKey: BluetoothObjectConstant.minorKey))
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(name, forKey: BluetoothObjectConstant.nameKey)
    aCoder.encode(uuid, forKey: BluetoothObjectConstant.uuidKey)
    aCoder.encode(Int(majorValue), forKey: BluetoothObjectConstant.majorKey)
    aCoder.encode(Int(minorValue), forKey: BluetoothObjectConstant.minorKey)
  }
  
}
