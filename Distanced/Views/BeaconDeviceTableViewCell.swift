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
    func removeInactiveCell(indexPath: IndexPath)
}

class BeaconDeviceTableViewCell: UITableViewCell {
    static let cellIdentifier = "BeaconDeviceTableViewCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emojiNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    weak var delegate: BeaconDeviceTableViewCellDelegate?
    
    private var remainingSeconds = 3
    private var countdownTimer: Timer?
    
    var shouldBeHidden = false
    
    private var oldDangerValue: GlobalVariables.BeaconDistanceDangerLevel = .relax
    var beacon: BeaconDeviceObject? = nil {
        didSet {
            oldDangerValue = oldValue?.getDistaceDangerLevel() ?? .relax
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
            containerView.backgroundColor = .clear
        }
    }
    
    private func updateContainerViewUI(beacon: BeaconDeviceObject) {
        let dangerLevel = beacon.getDistaceDangerLevel()
        
        if oldDangerValue != dangerLevel {
            UIView.animate(withDuration: 0.8) {
                switch dangerLevel {
                case .danger:
                    self.containerView.backgroundColor = .systemRed
                    self.startAnimation()
                    self.delegate?.beaconTooClose(beacon: beacon)
                    self.cancelInactiveCellTimer()
                case .caution:
                    self.stopAnimation()
                    self.containerView.backgroundColor = .systemOrange
                    self.cancelInactiveCellTimer()
                case .relax:
                    self.stopAnimation()
                    self.containerView.backgroundColor = .systemGreen
                    self.cancelInactiveCellTimer()
                default:
                    self.stopAnimation()
                    self.containerView.backgroundColor = .clear
                    self.initiateInactiveCellTimer()
                }
            }
        }
    }
    
    private func startAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.05
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        containerView.layer.add(animation, forKey: "pulsing")
    }
    
    private func stopAnimation() {
        containerView.layer.removeAllAnimations()
    }
    
    private func initiateInactiveCellTimer() {
        guard countdownTimer == nil else { return }
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.remainingSeconds -= 1
            if self?.remainingSeconds == 0 {
                timer.invalidate()
                self?.cancelInactiveCellTimer()
                if let nonEmptyIndexPath = self?.getIndexPath() {
                    self?.shouldBeHidden = true
                    self?.delegate?.removeInactiveCell(indexPath: nonEmptyIndexPath)
                }
            }
        }
    }
    
    private func cancelInactiveCellTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        shouldBeHidden = false
    }
    
    private func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else { return nil }
        
        let indexPath = superView.indexPath(for: self)
        return indexPath
    }
}
