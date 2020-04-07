//
//  BeaconDevicesViewController.swift
//  Distanced
//
//  Created by Maxim Zheleznyy on 4/1/20.
//  Copyright © 2020 Maxim Zheleznyy. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth


class BeaconDevicesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var manager: CBCentralManager!
    
    var knownBeaconsArray = [BeaconDeviceObject]()
    
    var needToShowLocationAlert = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager()
        manager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getLocationStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if needToShowLocationAlert {
            needToShowLocationAlert = false
            showNeedAuthAlert(title: "No Location Data", message: "App uses location to calculate distance between you and other people. \nOpen Settings to turn it on?")
        }
    }
    
    private func getLocationStatus() {
        locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startLookingForBeacons()
        case .restricted, .denied:
            needToShowLocationAlert = true
        default:
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    private func startLookingForBeacons() {
        guard let uuid = GlobalVariables.uuid else { return }
        
        if #available(iOS 13.0, *) {
            let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: GlobalVariables.identifier)
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(in: beaconRegion)
        } else {
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: GlobalVariables.identifier)
            locationManager.startRangingBeacons(in: beaconRegion)
        }
    }
    
    private func becameBeacon() {
        if localBeacon != nil {
            stopBeingBeacon()
        }
        
        guard let uuid = GlobalVariables.uuid else { return }
        let randomMajor = UInt16.random(in: 1...900)
        let randomMinor = UInt16.random(in: 1...900)
        
        if #available(iOS 13.0, *) {
            localBeacon = CLBeaconRegion(uuid: uuid, major: randomMajor, minor: randomMinor, identifier: GlobalVariables.identifier)
        } else {
            localBeacon = CLBeaconRegion(proximityUUID: uuid, major: randomMajor, minor: randomMinor, identifier: GlobalVariables.identifier)
        }
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    private func stopBeingBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
    }
    
    private func showNeedAuthAlert(title: String, message: String) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Open", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}

extension BeaconDevicesViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as? [String: Any])
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }
}

extension BeaconDevicesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: BeaconDeviceTableViewCell.cellIdentifier) as! BeaconDeviceTableViewCell
        
        let beacon = knownBeaconsArray[indexPath.row]
        cell.emojiNameLabel.text = beacon.emojiName
        cell.distanceLabel.text = beacon.locationString()

        if #available(iOS 13.0, *) {
            cell.emojiNameLabel?.textColor = .label
            cell.distanceLabel?.textColor = .secondaryLabel
        } else {
            cell.emojiNameLabel?.textColor = .black
            cell.distanceLabel?.textColor = .black
        }

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return knownBeaconsArray.count
    }
}

extension BeaconDevicesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {            
            var newDevice = BeaconDeviceObject(beacon: beacon)
            
            if let existingDeviceIndex = knownBeaconsArray.firstIndex(of: newDevice) {
                let oldDeviceObjectEmoji = knownBeaconsArray[existingDeviceIndex].emojiName
                newDevice.emojiName = oldDeviceObjectEmoji
                knownBeaconsArray[existingDeviceIndex] = newDevice
            } else {
                newDevice.emojiName = GlobalVariables.emojiArray.randomElement() ?? "🐶"
                knownBeaconsArray.append(newDevice)
            }
            
            tableView.reloadData()
        }
    }
}

extension BeaconDevicesViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            becameBeacon()
        case .poweredOff:
            showNeedAuthAlert(title: "Bluetooth Turned Off", message: "Your Bluetooth is turned off. \nDo you want to open Settings to turn it on?")
        default:
            showNeedAuthAlert(title: "No Bluetooth Data", message: "App uses bluetooth to calculate distance between you and other people. \nOpen Settings to turn it on?")
        }
    }
}
