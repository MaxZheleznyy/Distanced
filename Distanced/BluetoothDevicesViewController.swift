//
//  BluetoothDevicesViewController.swift
//  Distanced
//
//  Created by Maxim Zheleznyy on 4/1/20.
//  Copyright © 2020 Maxim Zheleznyy. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth


class BluetoothDevicesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    
    let localBeaconUUID = "CCDE4695-104E-4E86-BFB9-70EC5168A161"
    let randomMajor = UInt16.random(in: 1...900)
    let randomMinor = UInt16.random(in: 1...900)
    let identifier = "com.maxzheleznyy.Distanced"
    
    var knownBeaconsArray = [BluetoothDeviceObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        
        becameBeacon()
        startLookingForBeacons()
    }
    
    func becameBeacon() {
        if localBeacon != nil {
            stopBeingBeacon()
        }
        
        guard let uuid = UUID(uuidString: localBeaconUUID) else { return }
        if #available(iOS 13.0, *) {
            localBeacon = CLBeaconRegion(uuid: uuid, major: randomMajor, minor: randomMinor, identifier: identifier)
        } else {
            localBeacon = CLBeaconRegion(proximityUUID: uuid, major: randomMajor, minor: randomMinor, identifier: identifier)
        }
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func stopBeingBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
    }
    
    func startLookingForBeacons() {
        guard let uuid: UUID = UUID.init(uuidString: localBeaconUUID) else { return }
        
        if #available(iOS 13.0, *) {
            let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: identifier)
            locationManager.startMonitoring(for: beaconRegion)
            locationManager.startRangingBeacons(in: beaconRegion)
        } else {
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: identifier)
            locationManager.startRangingBeacons(in: beaconRegion)
        }
    }
}

extension BluetoothDevicesViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as? [String: Any])
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }
}

extension BluetoothDevicesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell

        let beacon = knownBeaconsArray[indexPath.row]
        cell.textLabel?.text = beacon.locationString()
        cell.detailTextLabel?.text = beacon.locationString()

        if #available(iOS 13.0, *) {
            cell.textLabel?.textColor = .label
            cell.detailTextLabel?.textColor = .secondaryLabel
        } else {
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
        }

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return knownBeaconsArray.count
    }
}

extension BluetoothDevicesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            var beaconUUID = UUID()
            
            if #available(iOS 13.0, *) {
                beaconUUID = beacon.uuid
            } else {
                beaconUUID = beacon.proximityUUID
            }
            
            let newDevice = BluetoothDeviceObject(identifier: identifier, uuid: beaconUUID, majorValue: Int(truncating: beacon.major), minorValue: Int(truncating: beacon.minor), beacon: beacon)
            if let existingDeviceIndex = knownBeaconsArray.firstIndex(of: newDevice) {
                knownBeaconsArray[existingDeviceIndex] = newDevice
            } else {
                knownBeaconsArray.append(newDevice)
            }
            
            tableView.reloadData()
        }
    }
}
