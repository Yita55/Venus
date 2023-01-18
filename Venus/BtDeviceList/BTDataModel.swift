//
//  BTDataModel.swift
//  Venus
//
//  Created by Kenneth on 20/06/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import Foundation
import CoreBluetooth
import EZAlertController
import SwiftProgressHUD
import RealmSwift

class BTDevice {
    // Device
    var advertisementData: String
    var localName: String
    var RSSI: NSNumber?
    var isConnected: Bool?
    var services: String?
    var characteristics: String?
    var peripheral: CBPeripheral?
    
    init (advertData: String, rssi: NSNumber, localName: String, peripheral: CBPeripheral) {
        advertisementData = advertData
        RSSI = rssi
        self.localName = localName
        self.peripheral = peripheral
    }
}

let kNewDeviceDiscovered: String = "newDeviceDiscovered"
let kNewDeviceConnected: String = "newDeviceConnected"
let kNotifyStep: String = "notifyStep"
let kNotifyHeartRate: String = "notifyHeartRate"
let kNotifyPower: String = "notifyPower"
let kNotifySwimData: String = "notifySwimData"
let kDeviceDisConnected: String = "deviceDisConnected"
let kBlePowerOff: String = "blePowerOff"

let kSyncHeartRateComplete: String = "syncHeartRateComplete"
let kSyncSleepComplete: String = "syncSleepComplete"
let kSyncSwimComplete: String = "syncSwimComplete"
let kSyncStepComplete: String = "syncStepComplete"

let kNotifyStepMode: String = "notifyStepMode"
let kNotifySwimMode: String = "notifySwimMode"

class BTDataModel: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // Data model, class for working with CoreBluetooth
    var btManager: CBCentralManager? //manager
    var btDevices = [BTDevice]()
    var btAvailable: Bool?
    var btSelectPeripheral: CBPeripheral?
    var btConnectedPeripheral: CBPeripheral?
    var btWriteCharacteristic: CBCharacteristic?
    var scanning: Bool = false
    var isBatteryLevelNotifEnable = false
    var batteryLevel = "0%"
    var alreadyReadDataCount: Int = 0
    // [55]:[F5]:[year]:[month]:[day]:[hour]:[minute]:[second]:[DoW]:00:00:00:00:00:00:00:00:00:00:00
    //var syncTimeBytes: [UInt8] = [0x55, 0xF5, 0x19, 0x0B, 0x0B, 0x09, 0x10, 0x04, 0x00, 0x00,
    //                              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
    var rscNotifyCharacteristics: CBCharacteristic?
    var isSyncAll = true
    
    static let sharedInstance = BTDataModel() //singleton
    
    var currentMode: Int = 0 {
        didSet {
            if currentMode == 1 {
                //====== notify UI change step mode ImageView
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotifyStepMode), object: nil)
                
            } else if currentMode == 2 {
                //====== notify UI change swim mode ImageView
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotifySwimMode), object: nil)
                
            } else {
                // ???
                //====== notify UI change no mode ImageView
                
            }
        }
    }
    
    override init () {
        super.init()
        // btManager = CBCentralManager.init(delegate: self, queue: nil) //Initialization of the manager
    }
    
    // CBManager Helpers
    func discover() {
        if btManager == nil {
            // ???
            //btManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true, CBCentralManagerOptionShowPowerAlertKey: true])
            btManager = CBCentralManager.init(delegate: self, queue: nil) //Initialization of the manager
        }
    }
    // We also need to stop scanning at some point so we'll also create a function that calls "stopScan"*/
    func cancelScan() {
        scanning = false
        if btManager != nil {
            btManager?.stopScan()
            btManager = nil
            print("Scan Stopped")
            print("Number of Peripherals(devices) Found: \(btDevices.count)")
        }
    }
    func isScanning() -> Bool {
        return scanning
    }
    func readValue(characteristic: CBCharacteristic!) {
        if characteristic != nil {
            //current_kiasu.peripheral.readValue(for: characteristic)
            //current_kiasu.peripheral.setNotifyValue(true, for: characteristic)
        } else {
            //current_kiasu.peripheral.discoverServices(nil)
        }
    }
    func writeValue(characteristic: CBCharacteristic!, rawData: Data!) {
        if characteristic != nil {
            //peripheral.delegate = self
            //peripheral.writeValue(rawData, for: characteristic, type: .withResponse)
        }
    }
    func scanForAvailableDevices () {
        if btManager != nil {
            btDevices.removeAll()
            scanning = true
            //btManager?.scanForPeripherals(withServices: nil, options: nil)
            btManager?.scanForPeripherals(withServices: [RUNNING_SPEED_AND_CADENCE_SERVICE_UUID] ,
                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
            // ???
            // btManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            // Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(self.cancelScan), userInfo: nil, repeats: false)
            
        }
        else {
            discover()
        }
    }
    func connectDevice() {
        if btManager != nil {
            btManager?.connect(btSelectPeripheral!, options: nil)
        }
    }
    //====== after bonded, change to main view, then start notify
    func startStepHeartRateNotify()
    {
        // step 5 接著打開RSC notification
        btConnectedPeripheral?.setNotifyValue(true, for: self.rscNotifyCharacteristics!)
    }
    
    // MARK: CBCentralManagerDelegate functions
    // 发现设备
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("------didDiscoverPeripheral------")
        print(advertisementData);
        // Receive parameters and form an instance of class BTDevice
        let manufacturer = advertisementData[CBAdvertisementDataManufacturerDataKey] == nil ? "" : String(describing: advertisementData[CBAdvertisementDataManufacturerDataKey])
        let name = advertisementData[CBAdvertisementDataLocalNameKey] == nil ? "No name" : String(describing: advertisementData[CBAdvertisementDataLocalNameKey]!)
        
        let btDevice = BTDevice(advertData: manufacturer + " " + name,
                                rssi: RSSI,
                                localName: name,
                                peripheral: peripheral)
        btDevices.append(btDevice)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNewDeviceDiscovered), object: nil)
    }
    // 设备已经接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("------didConnectPeripheral------")
        print("central=\(central)")
        print("peripheral=\(peripheral)")
        print("peripheral identifier=\(peripheral.identifier)")
        // 关闭扫描
        btManager?.stopScan()
        btConnectedPeripheral = peripheral
        btConnectedPeripheral?.delegate = self
        btConnectedPeripheral?.discoverServices(nil)
        print("扫描服务...")
        //====== Notify view control to update UI
        //NotificationCenter.default.post(name: Notification.Name(rawValue: kNewDeviceConnected), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNewDeviceConnected),
                                        object: self,
                                        userInfo: ["PeripheralName": btConnectedPeripheral!.name!])
    }
    
    func startScanPeripheral() {
        btManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
    }
    
    func disconnect(){
        print(">>>>>>>>> disconnect")
        if btConnectedPeripheral != nil {
            print("disconnecting.....")
            btManager?.cancelPeripheralConnection(btConnectedPeripheral!)
            startScanPeripheral()
            //btManager = nil
            btConnectedPeripheral = nil
            self.isBatteryLevelNotifEnable = false
            print("disconnected")
            
            self.currentMode = 0   // reset correntMode
        }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral - \(String(describing: error))")
        btConnectedPeripheral = nil
        NotificationCenter.default.post(name: Notification.Name(rawValue: kDeviceDisConnected),
                                        object: self,
                                        userInfo: ["PeripheralName": "nil"])
        
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Connection failed - \(String(describing: error))")
        
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Updating the status of the manager
        // print(central.state)
        switch central.state {
        case .unknown:
            print("CBCentralManagerStateUnknown")
            btAvailable = false
            btConnectedPeripheral = nil
            break
        case .resetting:
            print("CBCentralManagerStateResetting")
            btAvailable = false
            btConnectedPeripheral = nil
            break
        case .unsupported:
            print("CBCentralManagerStateUnsupported")
            btAvailable = false
            btConnectedPeripheral = nil
            break
        case .unauthorized:
            print("CBCentralManagerStateUnauthorized")
            btAvailable = false
            btConnectedPeripheral = nil
            break
        case .poweredOff:
            print("CBCentralManagerStatePoweredOff")
            btAvailable = false
            btConnectedPeripheral = nil
            NotificationCenter.default.post(name: Notification.Name(rawValue: kBlePowerOff), object: nil)
            break
        case .poweredOn:
            print("CBCentralManagerStatePoweredOn : scan for device!")
            scanForAvailableDevices()
            btAvailable = true
            break
        }
        /*
        switch central.state {
        case .poweredOn:
            scanForAvailableDevices()
            btAvailable = true
            break
        default:
            btAvailable = false
            break
        }
        */
    }
    
    // Peripheral Delegate Methods
    /**
     发现服务调用次方法
     
     - parameter peripheral: <#peripheral description#>
     - parameter error:      <#error description#>
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("------发现服务调用次方法------")
        print("didDiscoverServices!)")
        guard error == nil else {
            print("An error occured while discovering services: \(error!.localizedDescription)")
            btManager!.cancelPeripheralConnection(peripheral)
            return
        }
        
        // scan all
        /*
        var i = 0
        for service in peripheral.services! {
            i = i + 1
            peripheral.discoverCharacteristics(nil, for: service)
            print("(\(i)) \(service.uuid.uuidString)")
        }
        */
        
        for aService : CBService in peripheral.services! {
            // Discovers the characteristics for a given service
            if aService.uuid == RUNNING_SPEED_AND_CADENCE_SERVICE_UUID {
                peripheral.discoverCharacteristics([RSC_MEASUREMENT_CHARACTERISTIC_UUID], for: aService)
            } else if aService.uuid == BATTERY_SERVICE_UUID {
                peripheral.discoverCharacteristics([BATTERY_LEVEL_CHARACTERISTIC_UUID], for: aService)
            } else if aService.uuid == DEVICE_INFORMATION_SERVICE_UUID {
                peripheral.discoverCharacteristics([FIRMWARE_REVISION_STRING_CHARACTERISTIC_UUID], for: aService)
                peripheral.discoverCharacteristics([HARDWARE_REVISION_STRING_CHARACTERISTIC_UUID], for: aService)
            }
        }
    }
    /**
     根据服务找特征
     
     - parameter peripheral: <#peripheral description#>
     - parameter service:    <#service description#>
     - parameter error:      <#error description#>
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("------发现特征------")
        print("didDiscoverCharacteristicsFor!")
        guard error == nil else {
            print("Error occurred while discovering characteristic: \(error!.localizedDescription)")
            btManager!.cancelPeripheralConnection(peripheral)
            return
        }
        
        print("service = \(service.uuid.uuidString)")
        for c in service.characteristics! {
            //if c.uuid.uuidString == "2AF0"{
            //print(c.uuid.uuidString)
            //peripheral.setNotifyValue(true, for: c)
            //}
            //if c.uuid.uuidString == "2A53"{
            //    print(c.uuid.uuidString)
            //    btWriteCharacteristic = c
            //}
            print("    \(c.uuid.uuidString)")
        }
        
        // Characteristics for one of those services has been found
        // 1814
        if service.uuid == RUNNING_SPEED_AND_CADENCE_SERVICE_UUID {
            for aCharacteristic : CBCharacteristic in service.characteristics! {
                // 2A53
                if aCharacteristic.uuid == RSC_MEASUREMENT_CHARACTERISTIC_UUID {
                    
                    btWriteCharacteristic = aCharacteristic
                    // step 4 同步時間
                    /*
                    var writeParam : [UInt8] = []
                    var size  : NSInteger = 0
                    
                    writeParam.append(20)
                    size = 1
                    if size > 0 {
                        let data = Data(bytes: &writeParam, count: size)
                        print("Writing data: \(data) to \(aCharacteristic)")
                        peripheral.writeValue(data, for: aCharacteristic, type:.withResponse)
                    }
                    */
                    
                    /*
                    var rawArray:[UInt8] = [0x01];
                    let data = NSData(bytes: &rawArray, length: rawArray.count)
                    peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
                    */
                    
                    //self.writeToPeripheral(syncTimeBytes)
                    /*
                    let clock = Clock()
                    let formatter = DateFormatter()
                    formatter.timeStyle = .medium
                    let timeLabelString = formatter.string(from: clock.currentTime as Date)
                    */
                    
                    /*
                    DoW
                    Sunday
                    0  ->1
                    Monday
                    1  ->2
                    Tuesday
                    2  ->3
                    Wednesday
                    3  ->4
                    Thursday
                    4  ->5
                    Friday
                    5  ->6
                    Saturday
                    6  ->7
                    */
                    let date = NSDate()
                    let calendar = NSCalendar.current
                    let components = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second, .weekday], from: date as Date)
                    
                    let year = components.year! - 2000
                    let month = components.month!
                    let day = components.day!
                    let hour = components.hour!
                    let minute = components.minute!
                    let second = components.second!
                    let weekday = components.weekday! - 1
                    
                    
                    print(year)
                    print(month)
                    print(day)
                    print(hour)
                    print(minute)
                    print(second)
                    print(weekday)
                    
                    var writeParam : [UInt8] = [0x55, 0xF5, UInt8(year), UInt8(month), UInt8(day), UInt8(hour),
                                                UInt8(minute), UInt8(second), UInt8(weekday),  0x00,  0x00,  0x00,
                                                 0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00]
                    
                    /*  reset db
                    var writeParam : [UInt8] = [0x55, 0xFE, 0x00, 0x00, 0x00, 0x00,
                                                0x00, 0x00, 0x00,  0x00,  0x00,  0x00,
                                                0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00,  0x00]
                    */

                    var size  : NSInteger = 0
                    
                    // writeParam.append(20)
                    // size = 1
                    size = writeParam.count
                    if size > 0 {
                        let data = Data(bytes: &writeParam, count: size)
                        print("Writing data: \(writeParam) to \(aCharacteristic)")
                        peripheral.writeValue(data, for: aCharacteristic, type:.withResponse)
                    }
                    
                    /*
                     for test
                    let writeData: Data = dataWithHexstring(syncTimeBytes)
                    peripheral.writeValue(writeData, for: aCharacteristic, type:.withResponse)
                    */
                    
                    // step 5 接著打開RSC notification
                    // peripheral.setNotifyValue(true, for: aCharacteristic)
                    self.rscNotifyCharacteristics = aCharacteristic
                    break
                }
            }
        } else if service.uuid == BATTERY_SERVICE_UUID {
            // 180F
            for aCharacteristic : CBCharacteristic in service.characteristics! {
                // 2A19 step 1
                if aCharacteristic.uuid == BATTERY_LEVEL_CHARACTERISTIC_UUID {
                    peripheral.readValue(for: aCharacteristic)
                    break
                }
            }
        } else if service.uuid == DEVICE_INFORMATION_SERVICE_UUID {
            // 180A
            for aCharacteristic : CBCharacteristic in service.characteristics! {
                // 2A26 / 2A27 step 2
                if aCharacteristic.uuid == FIRMWARE_REVISION_STRING_CHARACTERISTIC_UUID {
                    peripheral.readValue(for: aCharacteristic)
                }
                else if aCharacteristic.uuid == HARDWARE_REVISION_STRING_CHARACTERISTIC_UUID {
                    peripheral.readValue(for: aCharacteristic)
                }
            }
        }
    }
    /**
     Start or stop listening for the value update action
     
     - parameter enable:         If you want to start listening, the value is true, others is false
     - parameter characteristic: The characteristic which provides notifications
     */
    func setNotification(enable: Bool, forCharacteristic characteristic: CBCharacteristic){
        if btConnectedPeripheral == nil {
            return
        }
        btConnectedPeripheral?.setNotifyValue(enable, for: characteristic)
    }
    /**
     发送指令到设备
     */
    func writeToPeripheral(_ bytes:[UInt8]) {
        if btWriteCharacteristic != nil {
            let writeData: Data = dataWithHexstring(bytes)
            
            btConnectedPeripheral?.writeValue(writeData,
                                             for: btWriteCharacteristic!,
                                             type: CBCharacteristicWriteType.withResponse)
        } else {
            // TODO
        }
    }
    
    func endQuery(type: UInt8) {
        let writeParam : [UInt8] = [0x55, type, 0x00, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        var size  : NSInteger = 0
        
        size = writeParam.count
        if size > 0 {
            print("End to query \(type) data: \(writeParam)!")
            self.writeToPeripheral(writeParam)
        }
        
        // hidden HUD
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            SwiftProgressHUD.hideAllHUD()
        }
        
        if self.isSyncAll {
            SwiftProgressHUD.showOnlyText( PropertyUtils.readLocalizedProperty("sync_complete") )
        }
        /// 模拟 1s后 加载完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            SwiftProgressHUD.hideAllHUD()
        }
    }
    
    /**
     将[UInt8]数组转换为NSData
     
     - parameter bytes: <#bytes description#>
     
     - returns: <#return value description#>
     */
    func dataWithHexstring(_ bytes: [UInt8]) -> Data {
        let data = Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
        return data
    }
    func readUInt8Value(ptr aPointer : inout UnsafeMutablePointer<UInt8>) -> UInt8 {
        let val = aPointer.pointee
        aPointer = aPointer.successor()
        return val
    }
    func encodeToString(_ hexBytes: [UInt8]) -> String {
        var outString = ""
        for val in hexBytes {
            // Prefix with 0 for values less than 16.
            if val < 16 { outString += "0" }
            outString += String(val, radix: 16)
        }
        return outString
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didWriteValueFor - \(String(describing: error))")
        
    }
    
    func enableSwimMode() {
        //Cloudchip defined data struct for swim mode
        
        // data format 20 bytes for CC defined swim mode data
        // [55]:[F4]:[01]:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00
        // bytes[0]: Send header 0x55
        // bytes[1]: Swim mode flag 0xF4
        // bytes[2]: Enable value
        // bytes[3~19]: Reserved
        let writeParam : [UInt8] = [0x55, 0xF4, 0x01, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        var size  : NSInteger = 0
        
        size = writeParam.count
        if size > 0 {
            print("Start to enable 0xF4 swim momde: \(writeParam)!")
            self.writeToPeripheral(writeParam)
        }
        
        SwiftProgressHUD.showOnlyText( PropertyUtils.readLocalizedProperty("swim_mode_starting") )
    }
    
    func disableSwimMode() {
        //Cloudchip defined data struct for swim mode
        
        // data format 20 bytes for CC defined swim mode data
        // [55]:[F4]:[01]:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00
        // bytes[0]: Send header 0x55
        // bytes[1]: Swim mode flag 0xF4
        // bytes[2]: Enable value
        // bytes[3~19]: Reserved
        let writeParam : [UInt8] = [0x55, 0xF4, 0x00, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        var size  : NSInteger = 0
        
        size = writeParam.count
        if size > 0 {
            print("Start to disable 0xF4 swim momde: \(writeParam)!")
            self.writeToPeripheral(writeParam)
        }
        SwiftProgressHUD.showOnlyText( PropertyUtils.readLocalizedProperty("swim_mode_stopped") )
    }
    
    func queryHistoryOfStepFA() {
        //[App Query] History data
        // [App Query] **History** data
        // [55]:[FA]:[01]:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00
        // bytes[0]: 0x55
        // bytes[1]: History data type
        //     0xFA: Step
        //     0xFB: Heart Rate
        //     0xFC: Sleep
        //     0xFD: Swim
        // bytes[2]: 00 for disable, 01 to enable
        // bytes[3~19]: Reserved
        let writeParam : [UInt8] = [0x55, 0xFA, 0x01, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        var size  : NSInteger = 0
        
        size = writeParam.count
        if size > 0 {
            print("Start to query 0xFA data: \(writeParam)!")
            self.alreadyReadDataCount = 0
            self.writeToPeripheral(writeParam)
        }
        
        SwiftProgressHUD.showOnlyText(PropertyUtils.readLocalizedProperty("syncing_data"))
    }
    
    func queryHistoryOfHeartRateFB() {
        //     0xFA: Step
        //     0xFB: Heart Rate
        //     0xFC: Sleep
        //     0xFD: Swim
        let writeParam : [UInt8] = [0x55, 0xFB, 0x01, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        var size  : NSInteger = 0
        
        size = writeParam.count
        if size > 0 {
            print("Start to query 0xFB data: \(writeParam)!")
            self.alreadyReadDataCount = 0
            self.writeToPeripheral(writeParam)
        }
        
        SwiftProgressHUD.showOnlyText(PropertyUtils.readLocalizedProperty("syncing_data"))
    }
    
    func queryHistoryOfSleepFC() {
        //     0xFA: Step
        //     0xFB: Heart Rate
        //     0xFC: Sleep
        //     0xFD: Swim
        let writeParam : [UInt8] = [0x55, 0xFC, 0x01, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        var size  : NSInteger = 0
        
        size = writeParam.count
        if size > 0 {
            print("Start to query 0xFC data: \(writeParam)!")
            self.alreadyReadDataCount = 0
            self.writeToPeripheral(writeParam)
        }
        
        
        
        
        SwiftProgressHUD.showOnlyText(PropertyUtils.readLocalizedProperty("syncing_data"))
    }
    
    func queryHistoryOfSwimFD() {
        //     0xFA: Step
        //     0xFB: Heart Rate
        //     0xFC: Sleep
        //     0xFD: Swim
        let writeParam : [UInt8] = [0x55, 0xFD, 0x01, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        var size  : NSInteger = 0
        
        size = writeParam.count
        if size > 0 {
            print("Start to query 0xFD data: \(writeParam)!")
            self.alreadyReadDataCount = 0
            self.writeToPeripheral(writeParam)
        }
        
        SwiftProgressHUD.showOnlyText(PropertyUtils.readLocalizedProperty("syncing_data"))
    }
    
    func decodeHistoryCount(countInt8Array: [UInt8]) -> Int {
        print("decodeHistoryCount: \(countInt8Array)")
        
        let littleEndianValue = countInt8Array.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1) { $0 })
            }.pointee
        
        return Int(UInt16(littleEndian: littleEndianValue))
    }
    
    func decodeHistoryIndex(indexInt8Array: [UInt8]) -> Int {
        print("decodeHistoryIndex: \(indexInt8Array)")
        
        let littleEndianValue = indexInt8Array.withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1) { $0 })
            }.pointee
        
        return Int(UInt16(littleEndian: littleEndianValue))
    }
    
    func insertToDB_0xFA(startTime: String,
                         endTime: String,
                         stepCount: Int,
                         stepState: Int,
                         stepCalorie: Int) {
        // step
        let realm = try! Realm()
        let stepObject = step()
        
        stepObject.start_time = startTime
        stepObject.end_time = endTime
        stepObject.step_count = stepCount
        stepObject.step_state = stepState
        stepObject.step_calorie = stepCalorie
        
        print("stepObject.id=\(stepObject.id)")
        
        try! realm.write {
            realm.add(stepObject, update: true)            
        }
    }
    
    func insertToDB_0xFB(time: String, valueOfHeartRate: Int) {
        let realm = try! Realm()
        let heartRate = heart_rate()
        
        heartRate.time = time
        heartRate.heart_rate_value = valueOfHeartRate
        
        try! realm.write {
            realm.add(heartRate, update: true)
        }
    }
    
    func insertToDB_0xFC(startTime: String,
                         duration: Int,
                         sleepState: Int) {
        // sleep
        let realm = try! Realm()
        let sleepObject = sleep()
        
        /*
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        //var startTime: String = "2017/9/5-12:13:20"
        let date = dateFormatter.date(from: startTime)
        print("Start: \(String(describing: date))")
        // Start: Optional(2000-01-01 19:00:00 +0000)
        */
        
        /*
        let dateG = NSDate(timeIntervalSince1970: TimeInterval(1500156532464/1000))
        "Jul 16, 2017, 6:08 AM"
        */
        
        sleepObject.start_time = startTime
        sleepObject.duration = duration
        sleepObject.sleep_state = sleepState
        
        try! realm.write {
            realm.add(sleepObject, update: true)
        }
    }
    
    func insertToDB_0xFD(startTime: String,
                         endTime: String,
                         strokeType: Int,
                         strokeCount: Int,
                         sectionNumber: Int,
                         poolSize: Int,
                         lapNumber: Int,
                         duration: Int) {
        // swim
        let realm = try! Realm()
        let swimObject = swim()
        
        swimObject.start_time = startTime
        swimObject.end_time = endTime
        swimObject.stroke_type = strokeType
        swimObject.stroke_count = strokeCount
        swimObject.section_num = sectionNumber
        swimObject.pool_size = poolSize
        swimObject.lap_num = lapNumber
        swimObject.duration = duration
        
        try! realm.write {
            realm.add(swimObject, update: true)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor!")
        guard error == nil else {
            print("Error occurred while updating characteristic value: \(error!.localizedDescription)")
            return
        }
        
        // ??? check if use main thread ???
        // Scanner uses other queue to send events. We must edit UI in the main queue
        //DispatchQueue.main.async(execute: {
            // Decode the characteristic data
            let data = characteristic.value
            var array = UnsafeMutablePointer<UInt8>(mutating: (data! as NSData).bytes.bindMemory(to: UInt8.self, capacity: data!.count))
            
            if characteristic.uuid == BATTERY_LEVEL_CHARACTERISTIC_UUID {
                let batteryLevel = self.readUInt8Value(ptr: &array)
                let text = "\(batteryLevel)%"
                print("batteryLevel=\(text)")
                //self.battery.setTitle(text , for: UIControlState.disabled)
                self.batteryLevel = text
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotifyPower),
                                                object: self,
                                                userInfo: ["BatteryLevel": text])
                
                
                //if self.battery.tag == 0 {
                if self.isBatteryLevelNotifEnable == false {
                    self.isBatteryLevelNotifEnable = true
                    // If battery level notifications are available, enable them
                    if characteristic.properties.rawValue & CBCharacteristicProperties.notify.rawValue > 0 {
                        // self.battery.tag = 1
                        // Enable notification on data characteristic
                        // step 3 讀完裝置資訊，打開電池notification
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                }
            } else if characteristic.uuid == FIRMWARE_REVISION_STRING_CHARACTERISTIC_UUID {
                print("FIRMWARE_REVISION!!!")
                
                let data:Data = characteristic.value!
                print(data)
                let d = Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count: data.count))
                print(d)
                let s: String = self.encodeToString(d)
                print(s)
                
                
                if let fwVersion = String(data: characteristic.value!, encoding: .utf8) {
                    print(fwVersion)
                    
                    UserDefaults.standard.set(fwVersion, forKey: UserDefaultsKey.FirmwareRevision)
                    
                } else {
                    print("not a valid UTF-8 sequence")
                }
                
                
            } else if characteristic.uuid == HARDWARE_REVISION_STRING_CHARACTERISTIC_UUID {
                print("HARDWARE_REVISION!!!")
                
                let data:Data = characteristic.value!
                print(data)
                let d = Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count: data.count))
                print(d)
                
                let s: String = self.encodeToString(d)
                print(s)
                
                // https://stackoverflow.com/questions/29643986/how-to-convert-uint8-byte-array-to-string-in-swift
                if let hwVersion = String(data: characteristic.value!, encoding: .utf8) {
                    print(hwVersion)
                    
                    UserDefaults.standard.set(hwVersion, forKey: UserDefaultsKey.HardwareRevision)
                    
                } else {
                    print("not a valid UTF-8 sequence")
                }
                
                // after read device information, enable RSC notification
                self.startStepHeartRateNotify()
                
                
                // 0821_2017, add show alert to check if get history ?
                EZAlertController.alert(PropertyUtils.readLocalizedProperty("sync_data"),
                                        message: PropertyUtils.readLocalizedProperty("sync_data_grant"),
                                        buttons: [PropertyUtils.readLocalizedProperty("Cancel"), PropertyUtils.readLocalizedProperty("ok")]) { (alertAction, position) -> Void in
                    if position == 0 {
                        print("CANCEL button clicked")
                    } else if position == 1 {
                        print("OK button clicked, Start to query!")
                        self.isSyncAll = true
                        self.queryHistoryOfStepFA()
                    }
                }
                
            } else if characteristic.uuid == RSC_MEASUREMENT_CHARACTERISTIC_UUID {
                //let flags = NORCharacteristicReader.readUInt8Value(ptr: &array)
                //let strideLengthPresent  = (flags & 0x01) > 0
                //let totalDistancePresent = (flags & 0x02) > 0
                //let running              = (flags & 0x04) > 0
                let data:Data = characteristic.value!
                //print(data)
                let d = Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count: data.count))
                //print(d)
                
                let _: String = self.encodeToString(d)
                //print(s)
                
                // ccf10135070000f2000000
                if d[0] == 0xCC {
                    // get step
                    if d[1] == 0xF1 {
                        
                        if self.currentMode != 1 {
                            self.currentMode = 1
                        }
                        
                        var stepValue: UInt32 = UInt32(littleEndian: 0)
                        var heartRateValue: UInt16 = UInt16(littleEndian: 0)
                        
                        if d[2] == 0x01 {
                            // read step
                            let stepArray: [UInt8] = [d[3], d[4], d[5], d[6]]
                            
                            
                            // https://stackoverflow.com/questions/32769929/convert-bytes-uint8-array-to-int-in-swift
                            
                            let littleEndianValue = stepArray.withUnsafeBufferPointer {
                                ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
                                }.pointee
                            stepValue = UInt32(littleEndian: littleEndianValue)
                            
                            
                            // bytes[11~14]: Calorie value
                            // read Calorie value
                            let calorieArray: [UInt8] = [d[11], d[12], d[13], d[14]]
                            
                            let calorieLittleEndianValue = calorieArray.withUnsafeBufferPointer {
                                ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
                                }.pointee
                            let calorieValue = UInt32(littleEndian: calorieLittleEndianValue)
                            
                            
                            print("Step=\(String(describing: stepValue))!")
                            print("calorieValue=\(calorieValue)!")
                            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotifyStep),
                                                            object: self,
                                                            userInfo: ["StepValue": stepValue,
                                                                       "StepCalorie": calorieValue])
                        }
                        else {
                            // ignore
                        }
                        
                        // get heat rate
                        if d[7] == 0xF2 {
                            if d[8] == 0x01 {
                                // read heart rate
                                let heartRateArray: [UInt8] = [d[9], d[10]]
                                
                                let littleEndianValue = heartRateArray.withUnsafeBufferPointer {
                                    ($0.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1) { $0 })
                                    }.pointee
                                heartRateValue = UInt16(littleEndian: littleEndianValue)
                                
                                print("HeartRate=\(String(describing: heartRateValue))!")
                                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotifyHeartRate),
                                                                object: self,
                                                                userInfo: ["HeateRate": heartRateValue])
                            }
                            else {
                                // ignore
                            }
                        }
                    }
                    else if d[1] == 0xF4 {
                        
                        if self.currentMode != 2 {
                            self.currentMode = 2
                        }
                        
                        // get swim data
                        // CC:F4:01:04: 1B:00:00:00 :01:00:00:00: 04:06:05:00
                        // StrokeType為BUTTERFLY，StrokeCount為27，Lap number為1
                        if d[2] == 0x01 {
                            // read swim data
                            var strokeType: String = "Others"
                            if d[3] == 0x00 {
                                strokeType = "Others"
                            } else if d[3] == 0x01 {
                                strokeType = "FRONTCRAWL"
                            } else if d[3] == 0x02 {
                                strokeType = "BACKSTROKE"
                            } else if d[3] == 0x03 {
                                strokeType = "BREASTSTROKE"
                            } else if d[3] == 0x04 {
                                strokeType = "BUTTERFLY"
                            } else if d[3] == 0x05 {
                                strokeType = "HEADUPBREAST"
                            }
                            print("strokeType=\(strokeType)!")
                            
                            let swimCountArray: [UInt8] = [d[4], d[5], d[6], d[7]]
                            
                            var littleEndianValue = swimCountArray.withUnsafeBufferPointer {
                                ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
                                }.pointee
                            let swimCountValue = UInt32(littleEndian: littleEndianValue)
                            
                            print("swimCountValue=\(swimCountValue)!")
                            
                            let swimLapArray: [UInt8] = [d[8], d[9], d[10], d[11]]
                            
                            littleEndianValue = swimLapArray.withUnsafeBufferPointer {
                                ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
                                }.pointee
                            let swimLapValue = UInt32(littleEndian: littleEndianValue)
                            
                            print("swimLapValue=\(swimLapValue)!")
                            
                            let swimStrokeTypeTimeLapArray: [UInt8] = [d[12], d[13], d[14], d[15]]
                            
                            littleEndianValue = swimStrokeTypeTimeLapArray.withUnsafeBufferPointer {
                                ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
                                }.pointee
                            let swimStrokeTypeTimeLapValue = UInt32(littleEndian: littleEndianValue)
                            
                            print("swimStrokeTypeTimeLapValue=\(swimStrokeTypeTimeLapValue)!")
                            
                            NotificationCenter.default.post(name: Notification.Name(rawValue: kNotifySwimData),
                                                            object: self,
                                                            userInfo: ["StrokeType": strokeType,
                                                                       "SwimCount32UInt": swimCountValue,
                                                                       "SwimLap32UInt": swimLapValue,
                                                                       "SwimStrokeTimeLap32UInt": swimStrokeTypeTimeLapValue])
                            
                        }
                        else {
                            // ignore
                        }
                    }
                    else if d[1] == 0xFA {
                        print("read 0xFA history data!")
                        // [Device Provide] Step **history** data
                        // [CC]:[FA]:[count x 2]:[index x 2]:[year]:[month]:[day]:[hour_start]:[minute_start]:[01]:[2F:00]:[hour_end]:[minute_end]:00:00:00:00
                        // bytes[0]: 0xCC
                        // bytes[1]: 0xFA Device sends **step history** data
                        // bytes[2~3]: Total count of data
                        // bytes[4~5]: Index of data
                        // bytes[6]: Year
                        // bytes[7]: Month
                        // bytes[8]: Day
                        // bytes[9]: Hour (start)
                        // bytes[10]: Minute (start)
                        // bytes[11]: Step State  
                        // bytes[12~13]: Step Count  
                        // bytes[14]: Hour (end)  
                        // bytes[15]: Minute (end)  
                        // bytes[16~19]: Reserved  
                        
                        // new FW change to below
                        // bytes[9]: Hour (start)
                        // bytes[10]: Minute (start)
                        // bytes[11]: Second (start)
                        // bytes[12]: Step State
                        // bytes[13~14]: Step Count
                        // bytes[15]: Hour (end)
                        // bytes[16]: Minute (end)  
                        // bytes[17]: Second (end)  
                        // bytes[18~19]: Calorie
                        
                        //ccfa 0b00 0100 11 08 11 00 35 01 2000 00 36
                        //ccfa0b00020011081108000110000800
                        //ccfa0b000500110811083b017801090a
                        //ccfa0b000a00110811132d0186021335
                        
                        //ccfa00000100
                        
                        // read step history
                        let totalCount: [UInt8] = [d[2], d[3]]
                        var totalCountValue: UInt16 = UInt16(littleEndian: 0)
                        
                        var littleEndianValue = totalCount.withUnsafeBufferPointer {
                            ($0.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1) { $0 })
                            }.pointee
                        totalCountValue = UInt16(littleEndian: littleEndianValue)
                        
                        print("Total Count=\(String(describing: totalCountValue))!")
                        
                        let dataIndex: [UInt8] = [d[4], d[5]]
                        var dataIndexValue: UInt16 = UInt16(littleEndian: 0)
                        
                        littleEndianValue = dataIndex.withUnsafeBufferPointer {
                            ($0.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1) { $0 })
                            }.pointee
                        dataIndexValue = UInt16(littleEndian: littleEndianValue)
                        
                        print("Data Index=\(String(describing: dataIndexValue))!")
                        
                        if totalCountValue > 0 {
                            // StartTime  11:08:07:12:33  =>  2017/8/7-18:51
                            let tmpYear = d[6]
                            let year = Int(tmpYear) + 2000
                            let month = Int(d[7])
                            let day = Int(d[8])
                            let startHour = Int(d[9])
                            let startMinute = Int(d[10])
                            let startSecond = Int(d[11])
                            
                            let startTime = String(format: "%04d/%02d/%02d-%02d:%02d:%02d", arguments: [year, month, day, startHour, startMinute, startSecond])
                            print("start time=\(startTime)")
                            //let startTime = "\(year)/\(month)/\(day)-\(startHour):\(startMinute):\(startSecond)"
                            //print("start time=\(startTime)")
                            
                            // byte 12 => 1 => WALK 2 => RUN
                            let stepState = Int(d[12])
                            print("step state=\(stepState)")
                            
                            // bytes[13~14]: Step Count
                            let stepCount: [UInt8] = [d[13], d[14]]
                            var stepCountValue: UInt16 = UInt16(littleEndian: 0)
                            
                            littleEndianValue = stepCount.withUnsafeBufferPointer {
                                ($0.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1) { $0 })
                                }.pointee
                            stepCountValue = UInt16(littleEndian: littleEndianValue)
                            
                            print("Step Count=\(String(describing: stepCountValue))!")
                            
                            
                            // bytes[15]: Hour (end)
                            // bytes[16]: Minute (end)
                            // bytes[17]: Second (end)
                            let endHour = Int(d[15])
                            let endMinute = Int(d[16])
                            let endSecond = Int(d[17])
                            
                            let endTime = String(format: "%04d/%02d/%02d-%02d:%02d:%02d", arguments: [year, month, day, endHour, endMinute, endSecond])
                            print("endTime=\(endTime)")
                            
                            //  bytes[18~19]: Calorie
                            let calorie: [UInt8] = [d[18], d[19]]
                            var calorieValue: UInt16 = UInt16(littleEndian: 0)
                            
                            littleEndianValue = calorie.withUnsafeBufferPointer {
                                ($0.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1) { $0 })
                                }.pointee
                            calorieValue = UInt16(littleEndian: littleEndianValue)
                            
                            print("calorieValue=\(String(describing: calorieValue))!")
                            
                            // weite to DB
                            // wait for information
                            self.insertToDB_0xFA(startTime: startTime,
                                                 endTime: endTime,
                                                 stepCount: Int(stepCountValue),
                                                 stepState: stepState,
                                                 stepCalorie: Int(calorieValue))
                            
                            // read complete
                            if totalCountValue == dataIndexValue {
                                self.alreadyReadDataCount += 1
                                
                                if self.alreadyReadDataCount == 7 {
                                    print("totalCountValue=dataIndexValue, and alreadyReadDataCount=7, read complete!")
                                    self.endQuery(type: 0xFA)
                                    if self.isSyncAll {
                                        self.queryHistoryOfHeartRateFB()
                                    } else {
                                        //====== notify view controller
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: kSyncStepComplete), object: nil)
                                        
                                    }
                                }
                            }
                            
                        } else {
                            self.alreadyReadDataCount += 1
                            
                            if self.alreadyReadDataCount == 7 {
                                // read complete
                                print("alreadyReadDataCount=7, read complete!")
                                self.endQuery(type: 0xFA)
                                if self.isSyncAll {
                                    self.queryHistoryOfHeartRateFB()
                                } else {
                                    //====== notify view controller
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: kSyncStepComplete), object: nil)
                                }
                            }
                        }
                    }
                    else if d[1] == 0xFB {
                        print("read 0xFB history data!")
                        // Heart Rate
                        // CC:FB:01:00:01:00:   11:08:09:11:15:0A:  39
                        // Count = 1
                        // Index = 1
                        // Time = 2017/8/9-17:21:10
                        // Heart Rate = 57
                        // read step history
                        let totalCount: [UInt8] = [d[2], d[3]]
                        let totalCountValue: Int = self.decodeHistoryCount(countInt8Array: totalCount)
                        let dataIndex: [UInt8] = [d[4], d[5]]
                        let dataIndexValue: Int = self.decodeHistoryIndex(indexInt8Array: dataIndex)
                        
                        print("Total Count=\(String(describing: totalCountValue))!")
                        print("Data Index=\(String(describing: dataIndexValue))!")
                        
                        if totalCountValue > 0 {
                            // time  11:08:07:12:33:0A  =>  2017/8/7-18:51:10
                            let tmpYear = d[6]
                            let year = Int(tmpYear) + 2000
                            let month = Int(d[7])
                            let day = Int(d[8])
                            let hour = Int(d[9])
                            let minute = Int(d[10])
                            let second = Int(d[11])
                              
                            //let startTime = "\(month)/\(day)/\(year) \(hour):\(minute):\(second)"
                            let startTime = String(format: "%02d/%02d/%04d %02d:%02d:%02d", arguments: [month, day, year, hour, minute, second])
                            print("start time=\(startTime)")
                            
                            let heartRate = Int(d[12])
                            print("heart rate=\(heartRate)")
                            
                            // weite to DB
                            // wait for information
                            self.insertToDB_0xFB(time: startTime,
                                                 valueOfHeartRate: heartRate)
                            
                            // read complete
                            if totalCountValue == dataIndexValue {
                                self.alreadyReadDataCount += 1
                                
                                if self.alreadyReadDataCount == 7 {
                                    print("totalCountValue=dataIndexValue, and alreadyReadDataCount=7, read complete!")
                                    self.endQuery(type: 0xFB)
                                    if self.isSyncAll {
                                        self.queryHistoryOfSleepFC()
                                    } else {
                                        //====== notify view controller
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: kSyncHeartRateComplete), object: nil)
                                    }
                                }
                            }
                            
                        } else {
                            self.alreadyReadDataCount += 1
                            
                            if self.alreadyReadDataCount == 7 {
                                // read complete
                                print("alreadyReadDataCount=7, read complete!")
                                self.endQuery(type: 0xFB)
                                if self.isSyncAll {
                                    self.queryHistoryOfSleepFC()
                                } else {
                                    //====== notify view controller
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: kSyncHeartRateComplete), object: nil)
                                }
                            }
                        }
                    }
                    else if d[1] == 0xFC {
                        print("read 0xFC history data!")
                        // Sleep
                        // CC:FC: 0D:00 : 01:00 : 11:08:04:  01:19:21: 02: ED:16:00:00
                        // count 13, index 1, time 2017/8/4-01:25:33, Duration 5869, state 2 => LIGHT, 1 => DEEP
                        // 清醒 (AWAKE)：
                        // AWAKE => 0
                        // ROLLOVER => 4
                        // 深睡眠 (DEEP)：
                        // DEEP => 1
                        // IDLE => 8
                        // 淺睡眠 (LIGHT)：
                        // LIGHT => 2
                        // CC:FC:0D:00:02:00:11:08:04:01:23:10:01:59:02:00:00
                        
                        // [Device Provide] Sleep **history** data
                        // [CC]:[FC]:[count x 2]:[index x 2]:[year]:[month]:[day]:[hour]:[minute]:[second]:[01]:[duration x 4]:00:00:00
                        // bytes[0]: 0xCC
                        // bytes[1]: 0xFC Device sends **sleep history** data
                        // bytes[2~3]: Total count of data
                        // bytes[4~5]: Index of data
                        // bytes[6]: Year
                        // bytes[7]: Month
                        // bytes[8]: Day
                        // bytes[9]: Hour (start)
                        // bytes[10]: Minute
                        // bytes[11]: Second
                        // bytes[12]: Sleep State
                        //     #define CC_SLEEPMETER_AWAKE          0x00000000
                        //     #define CC_SLEEPMETER_DEEPSLEEP      0x00000001
                        //     #define CC_SLEEPMETER_LIGHTSLEEP     0x00000002  
                        //     #define CC_SLEEPMETER_ROLLOVER       0x00000004  
                        //     #define CC_SLEEPMETER_IDLE           0x00000008  
                        // bytes[13~16]: Duration (Second)  
                        // bytes[17~19]: Reserved
                        let totalCount: [UInt8] = [d[2], d[3]]
                        let totalCountValue: Int = self.decodeHistoryCount(countInt8Array: totalCount)
                        let dataIndex: [UInt8] = [d[4], d[5]]
                        let dataIndexValue: Int = self.decodeHistoryIndex(indexInt8Array: dataIndex)
                        
                        print("Total Count=\(String(describing: totalCountValue))!")
                        print("Data Index=\(String(describing: dataIndexValue))!")
                        
                        if totalCountValue > 0 {
                            // StartTime  11:08:07:12:33  =>  2017/8/7-18:51
                            let tmpYear = d[6]
                            let year = Int(tmpYear) + 2000
                            let month = Int(d[7])
                            let day = Int(d[8])
                            let hour = Int(d[9])
                            let minute = Int(d[10])
                            let second = Int(d[11])
                            
                            let startTime = String(format: "%04d/%02d/%02d-%02d:%02d:%02d", arguments: [year, month, day, hour, minute, second])
                            print("start time=\(startTime)")
                            //let startTime = "\(year)/\(month)/\(day)-\(hour):\(minute):\(second)"
                            //print("start time=\(startTime)")
                            
                            // 12 byte : 0=awake, 1=deepsleep, 2=lightsleep, 4=rollover, 8=idle
                            let sleepState = Int(d[12])
                            print("sleep state=\(sleepState)")
                            
                            // bytes[13~16]: Duration (Second)
                            let duration: [UInt8] = [d[13], d[14], d[15], d[16]]
                            var durationValue: UInt32 = UInt32(littleEndian: 0)
                            let littleEndianValue = duration.withUnsafeBufferPointer {
                                ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
                                }.pointee
                            durationValue = UInt32(littleEndian: littleEndianValue)
                            
                            print("duration=\(String(describing: durationValue))!")
                            
                            // weite to DB
                            // wait for information
                            self.insertToDB_0xFC(startTime: startTime,
                                                 duration: Int(durationValue),
                                                 sleepState: sleepState)
                            
                            // read complete
                            if totalCountValue == dataIndexValue {
                                self.alreadyReadDataCount += 1
                                
                                if self.alreadyReadDataCount == 7 {
                                    print("totalCountValue=dataIndexValue, and alreadyReadDataCount=7, read complete!")
                                    self.endQuery(type: 0xFC)
                                    if self.isSyncAll {
                                        self.queryHistoryOfSwimFD()
                                    } else {
                                        //====== notify view controller
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: kSyncSleepComplete), object: nil)
                                    }
                                }
                            }
                            
                        } else {
                            self.alreadyReadDataCount += 1
                            
                            if self.alreadyReadDataCount == 7 {
                                // read complete
                                print("alreadyReadDataCount=7, read complete!")
                                self.endQuery(type: 0xFC)
                                if self.isSyncAll {
                                    self.queryHistoryOfSwimFD()
                                } else {
                                    //====== notify view controller
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: kSyncSleepComplete), object: nil)
                                }
                            }
                        }
                        
                    }
                    else if d[1] == 0xFD {
                        print("read 0xFD history data!")
                        // Swim
                        // CC:FD:09:00:01:00:01:20:11:08:09:01:1C:09:10:00:01:00:3E:00
                        // count=9, index=1, StartTime=2017/8/9-01:28:09 EndTime=2017/8/9-01:29:11 StrokeType=2 => Backstroke Stroke Count=16, Lap=1, Section=1, Duration=62, PoolSize=0
                        
                        // [Device Provide] Swim **history** data
                        // [CC]:[FD]:[count x 2]:[index x 2]:[01]:[41]:[year]:[month]:[day]:[hour]:[minute]:[second]:[20:00]:[01:00]:[30:00]
                        // bytes[0]: 0xCC
                        // bytes[1]: 0xFD Device sends **swim history** data
                        // bytes[2~3]: Total count of data
                        // bytes[4~5]: Index of data
                        // bytes[6]: Section number
                        // bytes[7]: Pool size and stroke type
                        //     Pool Size: (0~3 bits)
                        //     Stroke Type: (4~7 bits)
                        // bytes[8]: Year
                        // bytes[9]: Month
                        // bytes[10]: Day  
                        // bytes[11]: Hour  
                        // bytes[12]: Minute  
                        // bytes[13]: Second  
                        
                        // bytes[14~15]: Stroke count  
                        // bytes[16~17]: Lap number  
                        // bytes[18~19]: Duration (Second)
                        let totalCount: [UInt8] = [d[2], d[3]]
                        let totalCountValue: Int = self.decodeHistoryCount(countInt8Array: totalCount)
                        let dataIndex: [UInt8] = [d[4], d[5]]
                        let dataIndexValue: Int = self.decodeHistoryIndex(indexInt8Array: dataIndex)
                        
                        print("Total Count=\(String(describing: totalCountValue))!")
                        print("Data Index=\(String(describing: dataIndexValue))!")
                        
                        if totalCountValue > 0 {
                            let sectionNumber: Int = Int(d[6])
                            print("Section Number=\(sectionNumber)")
                            
                            // 0b 0000 1111 (0~3)
                            // 0b 1111 0000 (4~7)
                            let poolSizeStrokeType: UInt8 = d[7]
                            let poolSize: Int = Int(poolSizeStrokeType & 0x0F)
                            let strokeType: Int = Int(poolSizeStrokeType >> 4)
                            print("pool size=\(poolSize) stroke type=\(strokeType)")
                            
                            let tmpYear = d[8]
                            let year = Int(tmpYear) + 2000
                            let month = Int(d[9])
                            let day = Int(d[10])
                            let hour = Int(d[11])
                            let minute = Int(d[12])
                            let second = Int(d[13])
                            // StartTime=2017/8/9-01:28:09 EndTime=2017/8/9-01:29:11
                            let startTime = String(format: "%04d/%02d/%02d-%02d:%02d:%02d", arguments: [year, month, day, hour, minute, second])
                            print("start time=\(startTime)")
                            
                            // bytes[14~15]: Stroke Count
                            let strokeCount: [UInt8] = [d[14], d[15]]
                            var strokeCountValue: UInt16 = UInt16(littleEndian: 0)
                            var littleEndianValue = strokeCount.withUnsafeBufferPointer {
                                ($0.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1) { $0 })
                                }.pointee
                            strokeCountValue = UInt16(littleEndian: littleEndianValue)
                            print("Stroke Count=\(String(describing: strokeCountValue))!")
                            
                            // bytes[16~17]: Lap number
                            let lapNumber: [UInt8] = [d[16], d[17]]
                            var lapNumberValue: UInt16 = UInt16(littleEndian: 0)
                            littleEndianValue = lapNumber.withUnsafeBufferPointer {
                                ($0.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1) { $0 })
                                }.pointee
                            lapNumberValue = UInt16(littleEndian: littleEndianValue)
                            print("Lap Number=\(String(describing: lapNumberValue))!")
                            
                            // bytes[18~19]: Duration (Second)
                            let duration: [UInt8] = [d[18], d[19]]
                            var durationValue: UInt16 = UInt16(littleEndian: 0)
                            littleEndianValue = duration.withUnsafeBufferPointer {
                                ($0.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1) { $0 })
                                }.pointee
                            durationValue = UInt16(littleEndian: littleEndianValue)
                            print("duration=\(String(describing: durationValue))!")
                            
                            // 計算 end time
                            // Bug fix :
                            // startTime => startDate
                            // 2017/8/9-01:29:11
                            // let startTime = "\(year)/\(month)/\(day)-\(hour):\(minute):\(second)"
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
                            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                            
                            let startDate = dateFormatter.date(from: startTime)
                            //print(startDate)
                            let endDate = startDate!.addingTimeInterval( TimeInterval(Int(durationValue)) )
                            // endDate => endTime
                            //print(endDate)
                            
                            
                            /*
                            let calendar = NSCalendar.current
                            let components = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: endDate)
                            let endYear = components.year!
                            let endMonth = components.month!
                            let endDay = components.day!
                            let endHour = components.hour!
                            let endMinute = components.minute!
                            let endSecond = components.second!
                            */
                            
                            //let endTime = "\(endYear)/\(endMonth)/\(endDay)-\(endHour):\(endMinute):\(endSecond)"
                            let endTime = dateFormatter.string(from: endDate)
                            print("end time=\(endTime)")
                            // weite to DB
                            // wait for information
                            self.insertToDB_0xFD(startTime: startTime,
                                                 endTime: endTime,
                                                 strokeType: strokeType,
                                                 strokeCount: Int(strokeCountValue),
                                                 sectionNumber: sectionNumber,
                                                 poolSize: poolSize,
                                                 lapNumber: Int(lapNumberValue),
                                                 duration: Int(durationValue))
                            
                            // read complete
                            if totalCountValue == dataIndexValue {
                                self.alreadyReadDataCount += 1
                                
                                if self.alreadyReadDataCount == 7 {
                                    print("totalCountValue=dataIndexValue, and alreadyReadDataCount=7, read complete!")
                                    self.endQuery(type: 0xFD)
                                    
                                    if self.isSyncAll == false {
                                        //====== notify view controller
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: kSyncSwimComplete), object: nil)
                                    } else {
                                        do {
                                            var tmpList: Results<step>!
                                            let realm = try Realm()
                                            
                                            tmpList = realm.objects(step.self)
                                            SharingManager.sharedInstance.currentStepListCount = tmpList.count
                                        } catch let error as NSError {
                                            fatalError(error.localizedDescription)
                                        }
                                    }
                                }
                            }
                            
                        } else {
                            self.alreadyReadDataCount += 1
                            
                            if self.alreadyReadDataCount == 7 {
                                // read complete
                                print("alreadyReadDataCount=7, read complete!")
                                self.endQuery(type: 0xFD)
                                if self.isSyncAll == false {
                                    //====== notify view controller
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: kSyncSwimComplete), object: nil)
                                } else {
                                    do {
                                        var tmpList: Results<step>!
                                        let realm = try Realm()
                                        tmpList = realm.objects(step.self)
                                        SharingManager.sharedInstance.currentStepListCount = tmpList.count

                                    } catch let error as NSError {
                                        fatalError(error.localizedDescription)
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        //})
    }
    
}
