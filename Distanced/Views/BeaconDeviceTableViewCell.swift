//
//  BeaconDeviceTableViewCell.swift
//  Distanced
//
//  Created by Maxim Zheleznyy on 4/7/20.
//  Copyright © 2020 Maxim Zheleznyy. All rights reserved.
//

import UIKit

class BeaconDeviceTableViewCell: UITableViewCell {
    static let cellIdentifier = "BeaconDeviceTableViewCell"
    
    @IBOutlet weak var emojiNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var beacon: BeaconDeviceObject? = nil {
        didSet {
            if let nonEmptyBeacon = beacon {
                emojiNameLabel.text = nonEmptyBeacon.emojiName
                distanceLabel.text = nonEmptyBeacon.locationString()
            } else {
                emojiNameLabel.text = ""
                distanceLabel.text = ""
            }
        }
    }
}
