//
//  BeaconDeviceTableViewCell.swift
//  Distanced
//
//  Created by Maxim Zheleznyy on 4/7/20.
//  Copyright © 2020 Maxim Zheleznyy. All rights reserved.
//

import UIKit


protocol BeaconDeviceTableViewCellDelegate: AnyObject {
    func beaconTooClose(beacon: BeaconDeviceObject)
}

class BeaconDeviceTableViewCell: UITableViewCell {
    static let cellIdentifier = "BeaconDeviceTableViewCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emojiNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    weak var delegate: BeaconDeviceTableViewCellDelegate?
    
    var beacon: BeaconDeviceObject? = nil {
        didSet {
            configureCell()
        }
    }
    
    private func configureCell() {
        if #available(iOS 13.0, *) {
            emojiNameLabel?.textColor = .label
            distanceLabel?.textColor = .secondaryLabel
        } else {
            emojiNameLabel?.textColor = .black
            distanceLabel?.textColor = .black
        }
        
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
                self.delegate?.beaconTooClose(beacon: beacon)
            case .caution:
                self.containerView.backgroundColor = .systemOrange
            default:
                self.containerView.backgroundColor = .systemGreen
            }
        }
    }
}
