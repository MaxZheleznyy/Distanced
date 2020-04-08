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
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emojiNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var beacon: BeaconDeviceObject? = nil {
        didSet {
            configureCell()
        }
    }
    
    private func configureCell() {
        if let nonEmptyBeacon = beacon {
            emojiNameLabel.text = nonEmptyBeacon.emojiName
            distanceLabel.text = nonEmptyBeacon.locationString()
            updateContainerViewUI(beacon: nonEmptyBeacon)
        } else {
            emojiNameLabel.text = ""
            distanceLabel.text = ""
            containerView.backgroundColor = UIColor.white.withAlphaComponent(0)
        }
    }
    
    private func updateContainerViewUI(beacon: BeaconDeviceObject) {
        let dangerLevel = beacon.getDistaceDangerLevel()
        UIView.animate(withDuration: 0.8) {
            switch dangerLevel {
            case .danger:
                self.containerView.backgroundColor = .systemRed
            case .caution:
                self.containerView.backgroundColor = .systemOrange
            default:
                self.containerView.backgroundColor = .systemGreen
            }
        }
    }
}
