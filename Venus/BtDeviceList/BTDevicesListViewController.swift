//
//  BTDevicesListViewController.swift
//  Venus
//
//  Created by Kenneth on 20/06/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import UIKit
import EZAlertController

class BTDevicesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var disconnectBtn: UIButton!
    
    @IBAction func disconnectAction(_ sender: UIButton) {
        if btDataModel.btAvailable == true {
            if btDataModel.btConnectedPeripheral != nil {
                btDataModel.disconnect()
            }
            else {
                return
            }
        }
    }
    
    var btDataModel = BTDataModel.sharedInstance
    var updateTimer: Timer?
    var devices = [BTDevice]()
    var connectedDevice = [BTDevice]()
    var batteryLevel = "0%"
    var sectionTitles = [PropertyUtils.readLocalizedProperty("bonded"),
                         PropertyUtils.readLocalizedProperty("available")]
    let font15 = UIFont.systemFontOfSizeByScreenWidth(375.0, fontSize: 15.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(BTDevicesListViewController.receivedNewBluetoothDevice), name: NSNotification.Name(rawValue: kNewDeviceDiscovered), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BTDevicesListViewController.connectedBluetoothDevice(_:)), name: NSNotification.Name(rawValue: kNewDeviceConnected), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BTDevicesListViewController.disConnectedBluetoothDevice(_:)), name: NSNotification.Name(rawValue: kDeviceDisConnected), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BTDevicesListViewController.updateBatteryUI(_:)), name: NSNotification.Name(rawValue: kNotifyPower), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BTDevicesListViewController.blePoweredOffHandler), name: NSNotification.Name(rawValue: kBlePowerOff), object: nil)
        
        disconnectBtn.isEnabled = false
        self.styleEnableStatus(false)
        
        // self.navigationItem.setHidesBackButton(true, animated: false)
        
        /*
        override var isEnabled: Bool {
            didSet {
                if isEnabled {
                    self.styleEnableStatus(true)
                } else {
                    self.styleEnableStatus(false)
                }
            }
        */
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("BTDevicesListViewController :: viewWillAppear!")
        // init
        btDataModel.discover()
        
        self.disconnectBtn.isEnabled = false
        self.styleEnableStatus(false)
        
        if btDataModel.btConnectedPeripheral == nil ||
            btDataModel.btAvailable == false {
            self.disconnectBtn.isEnabled = false
            self.styleEnableStatus(false)
            
            // clear tableView
            blePoweredOffHandler()
            
            if btDataModel.btAvailable == true {
                btDataModel.scanForAvailableDevices()
                // refreshButton.setTitle("Update...", for: UIControlState())
                refreshButton.isEnabled = false
                updateTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(BTDevicesListViewController.timerFire), userInfo: nil, repeats: false)
            }
        } else {
            self.disconnectBtn.isEnabled = true
            self.styleEnableStatus(true)
            self.batteryLevel = btDataModel.batteryLevel
            devices = btDataModel.btDevices
            
            let tmpDevices = devices
            for i in 0 ..< devices.count {
                if tmpDevices[i].peripheral == btDataModel.btConnectedPeripheral {
                    connectedDevice.append(devices[i])
                    devices.remove(at: i)
                    print("device remove \(i)")
                    break
                }
            }
            // update cell UI
            DispatchQueue.main.async(execute: {
                self.disconnectBtn.isEnabled = true
                self.styleEnableStatus(true)
                self.emptyView.isHidden = true
                self.tableView.reloadData()
            })
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("BTDevicesListViewController - Stopping scan")
        // ???
        if btDataModel.btConnectedPeripheral == nil ||
            btDataModel.btAvailable == false {
            btDataModel.cancelScan()
        }
        
        if self.navigationController?.topViewController != self {
            print("back button tapped!")
            SharingManager.sharedInstance.isBackFromHeartRateHistory = true
            SharingManager.sharedInstance.isBackFromStepHistory = true
        }
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)        
    }
    
    @IBAction func refreshButtonTap(_ sender: AnyObject) {
        // Click on the "Update" button
        if btDataModel.btConnectedPeripheral != nil {
            return
        }
        
        if btDataModel.btAvailable == true {
            btDataModel.scanForAvailableDevices()
            //refreshButton.setTitle("Update...", for: UIControlState())
            refreshButton.isEnabled = false
            updateTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(BTDevicesListViewController.timerFire), userInfo: nil, repeats: false)
        }
        else
        {
            EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"),
                                    message: PropertyUtils.readLocalizedProperty("You must turn on Bluetooth!"),
                                    acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
                print("cliked OK")
            }
            emptyView.isHidden = false
            devices.removeAll()
            connectedDevice.removeAll()
            tableView.reloadData()
        }
        
    }
    
    func blePoweredOffHandler() {
        DispatchQueue.main.async(execute: {
            self.disconnectBtn.isEnabled = false
            self.styleEnableStatus(false)
            self.emptyView.isHidden = false
            self.devices.removeAll()
            self.connectedDevice.removeAll()
            self.tableView.reloadData()
        })
    }
    
    //MARK : NotificationsHandler
    func receivedNewBluetoothDevice () {
        // Processing of notification of information and new device
        devices = btDataModel.btDevices
        if devices.count > 0 {
            DispatchQueue.main.async(execute: {
                self.emptyView.isHidden = true
                self.tableView.reloadData()
            })
        }
    }
    
    func connectedBluetoothDevice(_ notification: Notification) {
        guard let peripheralName = (notification as NSNotification).userInfo?["PeripheralName"] else {
            return
        }
        print("BTDevicesListViewController - connectedBluetoothDevice :: peripheralName=\(peripheralName)")
        
        print("devices.count=\(devices.count)")
        let tmpDevices = devices
        for i in 0 ..< devices.count {
            if tmpDevices[i].peripheral == btDataModel.btConnectedPeripheral {
                connectedDevice.append(devices[i])
                UserDefaults.standard.set(peripheralName, forKey: UserDefaultsKey.DeviceName)
                devices.remove(at: i)
                print("device remove \(i)")
                break
            }
        }
        // update cell UI
        DispatchQueue.main.async(execute: {
            self.disconnectBtn.isEnabled = true
            self.styleEnableStatus(true)
            //self.tableView.reloadData()
        })
    }
    
    func disConnectedBluetoothDevice(_ notification: Notification) {
        guard let peripheralName = (notification as NSNotification).userInfo?["PeripheralName"] else {
            return
        }
        print("BTDevicesListViewController - disConnectedBluetoothDevice :: peripheralName=\(peripheralName)")
        
        // update cell UI
        DispatchQueue.main.async(execute: {
            self.disconnectBtn.isEnabled = false
            self.styleEnableStatus(false)
            self.emptyView.isHidden = false
            self.devices.removeAll()
            self.connectedDevice.removeAll()
            self.tableView.reloadData()
        })
        
        btDataModel.discover()
        if btDataModel.btAvailable == true {
            btDataModel.scanForAvailableDevices()
            // refreshButton.setTitle("Update...", for: UIControlState())
            refreshButton.isEnabled = false
            updateTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(BTDevicesListViewController.timerFire), userInfo: nil, repeats: false)
        }
        
    }
    
    func updateBatteryUI(_ notification: Notification) {
        let batteryLevel = (notification as NSNotification).userInfo?["BatteryLevel"] as! String
        
        print("BTDevicesListViewController - updateBatteryUI :: BatteryLevel=\(batteryLevel)")
        
        DispatchQueue.main.async(execute: {
            self.batteryLevel = batteryLevel
            // update cell UI
            self.tableView.reloadData()
        })
    }
    
    func styleEnableStatus(_ enable: Bool) {
        
        if enable {
            //self.disconnectBtn.backgroundColor = UIColor(red: 82 / 255, green: 211 / 255, blue: 68 / 255, alpha: 1)
            self.disconnectBtn.backgroundColor = UIColor.red
            //self.backgroundColor = UIColor(hex: 0xffffff, alpha: 1.0)
            self.disconnectBtn.titleLabel?.textColor = UIColor(hex: 0xffffff, alpha: 1.0)
            
        } else {
    
            //self.disconnectBtn.backgroundColor = UIColor(red: 200 / 255, green: 199 / 255, blue: 204 / 255, alpha: 1)
            self.disconnectBtn.backgroundColor = UIColor(hex: 0xc7c8cc, alpha: 1.0)
            self.disconnectBtn.titleLabel?.textColor = UIColor(hex: 0xffffff, alpha: 1.0)
            self.disconnectBtn.titleLabel?.textColor = UIColor(hex: 0x5e5e5e, alpha: 1.0)
        }
    }
    
    func timerFire () {
        //refreshButton.setTitle("Update", for: UIControlState())
        refreshButton.isEnabled = true
    }
    
    // MARK : TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        if btDataModel.btAvailable == false {
            return 0
        }
        //if btDataModel.btConnectedPeripheral == nil {
        //    return 1
        //} else {
            return sectionTitles.count
        //}
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if btDataModel.btAvailable == false {
            return 0
        }
        
        if section == 0 {
            if btDataModel.btConnectedPeripheral != nil {
                return connectedDevice.count
            } else {
                return 0
            }
        } else {
            //if btDataModel.btConnectedPeripheral == nil {
                return devices.count
            //} else {
            //    return (devices.count - 1)
            //}
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if btDataModel.btConnectedPeripheral == nil {
            return nil
        }
        if connectedDevice.count == 1 {
            return sectionTitles[section]
        } else {
            return nil
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let identifier = "cell"
        //let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceCell

        switch indexPath.section {
        // connected BLE
        case 0:
            let device = connectedDevice[indexPath.row]
            
            cell.nameLabel.text = device.localName
            if let rssi = device.RSSI {
                let rssiInt: Int = rssi.intValue
                
                if rssiInt > 0 {
                    cell.rssiLabel.text = "RSSI: " + "N/A"
                } else {
                    cell.rssiLabel.text = "RSSI: " + String(describing: rssiInt)
                }
            }
            //if btDataModel.btConnectedPeripheral == device.peripheral {
                cell.connectStatusLabel.text = PropertyUtils.readLocalizedProperty("connected")
                cell.connectStatusLabel.textColor = UIColor.blue
                cell.batteryLevelLabel.text = self.batteryLevel
                cell.batteryLevelLabel.isHidden = false
                cell.batteryImageView.isHidden = false
            //}
            break
        // not connected BLE
        case 1:
            let device = devices[indexPath.row]
            
            cell.nameLabel.text = device.localName
            // cell.rssiLabel.text = "RSSI: " + String(describing: device.RSSI!)
            if let rssi = device.RSSI {
                let rssiInt: Int = rssi.intValue
                
                if rssiInt > 0 {
                    cell.rssiLabel.text = "RSSI: " + "N/A"
                } else {
                    cell.rssiLabel.text = "RSSI: " + String(describing: rssiInt)
                }
            }
            cell.connectStatusLabel.text = PropertyUtils.readLocalizedProperty("click to connect device")
            cell.connectStatusLabel.textColor = UIColor.red
            cell.batteryLevelLabel.isHidden = true
            cell.batteryImageView.isHidden = true
            
            break
        default:
            break
        }
        
        cell.nameLabel.font = font15
        cell.rssiLabel.font = font15
        cell.connectStatusLabel.font = font15
        cell.batteryLevelLabel.font = font15
    
        /*
        let device = devices[indexPath.row]
         
        cell.nameLabel.text = device.localName
        cell.rssiLabel.text = "RSSI: " + String(describing: device.RSSI!)
        if btDataModel.btConnectedPeripheral == device.peripheral {
            cell.connectStatusLabel.text = PropertyUtils.readLocalizedProperty("已連線")
            cell.connectStatusLabel.textColor = UIColor.blue
            cell.batteryLevelLabel.text = self.batteryLevel
            cell.batteryLevelLabel.isHidden = false
            cell.batteryImageView.isHidden = false
        }
        else {
            cell.connectStatusLabel.text = PropertyUtils.readLocalizedProperty("點擊後開始連線設備")
            cell.connectStatusLabel.textColor = UIColor.red
            //cell.batteryLevelLabel.text = "??" + "%"
            cell.batteryLevelLabel.isHidden = true
            cell.batteryImageView.isHidden = true
        }
        */
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if btDataModel.btAvailable == true {
            if btDataModel.btConnectedPeripheral == nil {
                let selectDevice = devices[indexPath.row]
        
                btDataModel.btSelectPeripheral = selectDevice.peripheral
                btDataModel.connectDevice()
            }
            else {
                EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"),
                                        message: PropertyUtils.readLocalizedProperty("connected"),
                                        acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
                                            print("cliked OK")
                }
            }
        }
        else {
            EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"),
                                    message: PropertyUtils.readLocalizedProperty("You must turn on Bluetooth!"),
                                    acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
                                        print("cliked OK")
            }
            
            emptyView.isHidden = false
            devices.removeAll()
            connectedDevice.removeAll()
            tableView.reloadData()
        }
        
    }
    
}

