/*
 * Copyright (C) 2016 Xu,Cheng Wei <www16852@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
//
//  SectionManager.swift
//  Settings
//
//  Created by waltoncob on 2016/10/21.
//  Copyright © 2016年 waltoncob. All rights reserved.
//

import Foundation
import CoreBluetooth

public class PlistManager {

    private var cellContents:[CellContent] = []
    private var dictionary:[String:Any] = [:]
    var btDataModel = BTDataModel.sharedInstance

    private let rootPath = NSSearchPathForDirectoriesInDomains(
        .documentDirectory,
        .userDomainMask,
        true)[0]

    public var plistPathInDocument:String{
        get{
            return rootPath + "/Settings.plist"
        }
    }

    public init(){

    }

    public func setup(cellContents:[CellContent]){
        self.cellContents = cellContents
        if openPlist() == false{
            buildDictionary()
            savePlist()
        }
    }

    //MARK:get set

    //MARK:Dictionary

    func buildDictionary(){
        var oriValue: String = ""
        
        for content in cellContents{
            let key = content.getKey()
            let value = content.getValue()
            
            oriValue = value as! String
            print("buildDictionary= [\(key) \(customerValueMapping(oriValue: oriValue))]!")
            self.dictionary[key] = customerValueMapping(oriValue: oriValue)
        }
    }
    
    private func customerValueMapping(oriValue: String) -> String {
        // bug fix :
        var tmpValue: String = oriValue
        
        if tmpValue == "開" || tmpValue == "开" {
            tmpValue = "ON"
        } else if tmpValue == "關" || tmpValue == "关" {
            tmpValue = "OFF"
        } else if tmpValue == "左手" {
            tmpValue = "Left hand"
        } else if tmpValue == "右手" {
            tmpValue = "Right hand"
        } else if tmpValue == "男" {
            tmpValue = "male"
        } else if tmpValue == "女" {
            tmpValue = "female"
        } else if tmpValue == "25公尺" || tmpValue == "25公尺" {
            tmpValue = "25m"
        } else if tmpValue == "50公尺" || tmpValue == "50公尺" {
            tmpValue = "50m"
        } else if tmpValue == "25碼" || tmpValue == "25码" {
            tmpValue = "25yd"
        } else if tmpValue == "33 1/3公尺" || tmpValue == "33 1/3公尺" {
            tmpValue = "33 1/3m"
        } else if tmpValue == "33 1/3碼" || tmpValue == "33 1/3码" {
            tmpValue = "33 1/3yd"
        } else if tmpValue == "公分/公里" {
            tmpValue = "cm/km"
        } else if tmpValue == "英吋/英哩" {
            tmpValue = "in/mi"
        } else if tmpValue == "公斤" {
            tmpValue = "kg"
        } else if tmpValue == "磅" {
            tmpValue = "lbs"
        }  
        
        return tmpValue
    }
    
    public func adjustCellContents() {
        var oriValue: String = ""
        
        for content in cellContents{
            let key = content.getKey()
            print("adjustCellContents= [\(key)]!")
            if let plistValue = dictionary[key] {
                print("adjustCellContents= [\(plistValue)]!")
                
                oriValue = plistValue as! String
                content.set(value: customerValueMapping(oriValue: oriValue))
            }
        }
    }
    
    // 0801_2017, add
    public func setCellContent(key: String, value: String) {
        for content in cellContents{
            if key == content.getKey() {
                content.set(value: customerValueMapping(oriValue: value))
                print("key=\(key) value=\(customerValueMapping(oriValue: value))!")
                savePlist()
            }
        }
    }
    
    public func getCellContent(key: String) -> String {
        if let plistValue = dictionary[key] {
            return plistValue as! String
        }
        return "ERROR"
    }

    //MARK:Plist

    func openPlist() -> Bool{
        if FileManager.default.fileExists(atPath: plistPathInDocument){
            dictionary = NSDictionary(contentsOfFile: plistPathInDocument) as! [String : Any]
            return true
        }else{
            return false
        }
    }

    func savePlist(){
        print("savePlist!")
        buildDictionary()
        let nsDictionary = dictionary as NSDictionary
        if nsDictionary.write(toFile:plistPathInDocument, atomically:true) == false {
            print("Settings: Plist creat fail")
            return
        }
        
        let birthday = self.getCellContent(key: "birthday")
        let age = computeAge(birthday: birthday)
        UserDefaults.standard.set(age, forKey: UserDefaultsKey.Age)
        
        print("stat to write to BLE device!")
        if btDataModel.btAvailable == true {
            if btDataModel.btConnectedPeripheral != nil {
                // data format 20 bytes for CC defined alerts data
                // [55]:[F6]:[01]:[01]:[01]:[01]:[01]:[01]:00:00:00:00:00:00:00:00:00:00:00:00
                // bytes[0]: Send header 0x55
                // bytes[1]: Alerts data flag 0xF6
                // bytes[2]: Incoming call (0: disabled, 1: enabled, 2: incoming, 3: answered/missed call/hang up)
                // bytes[3]: Incoming SMS (0: disabled, 1: enabled, 2: incoming)
                // bytes[4]: Idle alert
                // bytes[5]: Lift wrist (Lift arm)
                // bytes[6]: Heart Rate Strap Mode
                // bytes[7]: Heart Rate 24-Hour Monitor
                // bytes[8]: 24-Hour Periodic Measurement Time - Hour
                // bytes[9]: 24-Hour Periodic Measurement Time - Minute
                // bytes[10]: 24-Hour Periodic Measurement Time - Second
                // bytes[11]: 24-Hour One Measurement Max Time - Hour
                // bytes[12]: 24-Hour One Measurement Max Time - Minute  
                // bytes[13]: 24-Hour One Measurement Max Time - Second  
                // bytes[14~19]: Reserved
                
                let idleAlert = self.getCellContent(key: "smart_alerts_idle")
                let liftWrist = self.getCellContent(key: "lift_wrist_view")
                let heartRateStrap = self.getCellContent(key: "heart_rate_strap_mode")
                let heartRateMonitor = self.getCellContent(key: "heart_rate_24hr_monitor")
                
                print("idleAlert=\(idleAlert)")
                print("liftWrist=\(liftWrist)")
                print("heartRateStrap=\(heartRateStrap)")
                print("heartRateMonitor=\(heartRateMonitor)")
                
                var flagOfIdleAlert: Int = 0
                var flagOfLiftWrist: Int = 0
                var flagOfHeartRateStrap: Int = 0
                var flagOfHeartRateMonitor: Int = 0
                
                if idleAlert == "ON" {
                    flagOfIdleAlert = 1
                } else {
                    flagOfIdleAlert = 0
                }
                
                if liftWrist == "ON" {
                    flagOfLiftWrist = 1
                } else {
                    flagOfLiftWrist = 0
                }
                
                if heartRateStrap == "ON" {
                    flagOfHeartRateStrap = 1
                } else {
                    flagOfHeartRateStrap = 0
                }
                
                if heartRateMonitor == "ON" {
                    flagOfHeartRateMonitor = 1
                } else {
                    flagOfHeartRateMonitor = 0
                }
                
                var writeParam : [UInt8] = [0x55, 0xF6, UInt8(1), UInt8(1), UInt8(flagOfIdleAlert), UInt8(flagOfLiftWrist),
                                            UInt8(flagOfHeartRateStrap), UInt8(flagOfHeartRateMonitor), 0x00, 0x00, 0x00, 0x00, 0x00,
                                            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
                var size  : NSInteger = 0

                size = writeParam.count
                if size > 0 {
                    let data = Data(bytes: &writeParam, count: size)
                    print("Writing alert data: \(data) \(writeParam)!")
                    btDataModel.writeToPeripheral(writeParam)
                    let _: Timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(writeUserDataToBLE), userInfo: nil, repeats: false)
                }
                
            } else {
                print("BT not connect!")
            }
        } else {
            print("BT not available!")
        }
    }
    
    func computeAge(birthday: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let bDate = dateFormatter.date(from: birthday)!
        
        let now = Date()
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year], from: bDate, to: now)
        var age = ageComponents.year!

        if age < 0 {
            age = 0
        }
        
        return Int(age)
    }
    
    @objc func writeUserDataToBLE() {
        let height = Int(self.getCellContent(key: "height"))!
        let weight = Int(self.getCellContent(key: "weight"))!
        let birthday = self.getCellContent(key: "birthday")
        let gender = self.getCellContent(key: "gender")
        let strideLength = Int(self.getCellContent(key: "stride_len"))!
        let swimPoolSize = self.getCellContent(key: "swim_pool_size")
        let bandLocation = self.getCellContent(key: "band_location")
        
        print("height=\(height)")
        print("weight=\(weight)")
        print("birthday=\(birthday)")
        print("gender=\(gender)")
        print("strideLength=\(strideLength)")
        print("swimPoolSize=\(swimPoolSize)")
        print("bandLocation=\(bandLocation)")
        
        var valueOfGender = 0
        var valueOfSwimPoolSize = 1
        var valueOfBandLocation = 0
        
        print("\(PropertyUtils.readLocalizedProperty("male"))")
        
        if gender == "male" {
            valueOfGender = 0
        } else {
            valueOfGender = 1
        }
        
        print("\(PropertyUtils.readLocalizedProperty("25m"))")
        if swimPoolSize == "25m" {
            valueOfSwimPoolSize = 0
        } else if swimPoolSize == "50m" {
            valueOfSwimPoolSize = 1
        } else if swimPoolSize == "25yd" {
            valueOfSwimPoolSize = 2
        } else if swimPoolSize == "33 1/3m" {
            valueOfSwimPoolSize = 3
        } else {
            valueOfSwimPoolSize = 4
        }
        
        // bytes[8]: Band location (0: Left hand, 1: Right hand)  
        // ???
        print("\(PropertyUtils.readLocalizedProperty("Right hand"))")
        if bandLocation == "Right hand" {
            valueOfBandLocation = 1
        } else {
            valueOfBandLocation = 0
        }
        
        let age = computeAge(birthday: birthday)
        
        
        UserDefaults.standard.set(age, forKey: UserDefaultsKey.Age)
        
        var writeParam : [UInt8] = [0x55, 0xF7, UInt8(height), UInt8(weight), UInt8(age), UInt8(valueOfGender),
                                    UInt8(strideLength), UInt8(valueOfSwimPoolSize), UInt8(valueOfBandLocation), 0x96, 0x28, 0xA1, 0x28,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        var size  : NSInteger = 0
        
        size = writeParam.count
        if size > 0 {
            let data = Data(bytes: &writeParam, count: size)
            print("Writing user data: \(data) \(writeParam)!")
            btDataModel.writeToPeripheral(writeParam)
            let _: Timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(writeUnitDataToBLE), userInfo: nil, repeats: false)
        }
    }
    
    @objc func writeUnitDataToBLE() {
        
        let lengthUnit = self.getCellContent(key: "units_length")
        let weightUnit = self.getCellContent(key: "units_weight")
        
        print("lengthUnit=\(lengthUnit)")
        print("lengthUnit=\(lengthUnit)")
        
        
        var valueOfLengthUnit = 0
        var valueOfWeightUnit = 0
        
        if lengthUnit == "cm/km" {
            valueOfLengthUnit = 0
        } else {
            valueOfLengthUnit = 1
        }
        
        if weightUnit == "kg" {
            valueOfWeightUnit = 0
        } else {
            valueOfWeightUnit = 1
        }
        
        var writeParam : [UInt8] = [0x55, 0xF8, UInt8(valueOfLengthUnit), UInt8(valueOfWeightUnit), 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        var size  : NSInteger = 0
        
        size = writeParam.count
        if size > 0 {
            let data = Data(bytes: &writeParam, count: size)
            print("Writing unit data: \(data) \(writeParam)!")
            btDataModel.writeToPeripheral(writeParam)
            let _: Timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(writeSleepTimeDataToBLE), userInfo: nil, repeats: false)
        }
    }
    
    @objc func writeSleepTimeDataToBLE() {
        
        // data format 20 bytes for CC defined sleep time data
        // [55]:[F3]:[16]:[00]:[10]:[00]:00:00:00:00:00:00:00:00:00:00:00:00:00:00
        // bytes[0]: Send header 0x55
        // bytes[1]: Sleep data flag 0xF3
        // bytes[2]: Start hour
        // bytes[3]: Start minute
        // bytes[4]: End hour
        // bytes[5]: End minute
        // bytes[6~19]: Reserved

        // 00:00 ~ 00:00
        let sleepTime = self.getCellContent(key: "sleep_time")
        let startSleepTime = sleepTime.components(separatedBy: "~")[0]
        let endSleepTime = sleepTime.components(separatedBy: "~")[1]
        let valueOfStartHour = Int(startSleepTime.components(separatedBy: ":")[0])!
        let valueOfStartMinute = Int(startSleepTime.components(separatedBy: ":")[1])!
        let valueOfEndHour = Int(endSleepTime.components(separatedBy: ":")[0])!
        let valueOfEndMinute = Int(endSleepTime.components(separatedBy: ":")[1])!
        
        var writeParam : [UInt8] = [0x55, 0xF3,
                                    UInt8(valueOfStartHour),
                                    UInt8(valueOfStartMinute),
                                    UInt8(valueOfEndHour),
                                    UInt8(valueOfEndMinute),
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
        var size  : NSInteger = 0
        
        size = writeParam.count
        if size > 0 {
            let data = Data(bytes: &writeParam, count: size)
            print("Writing Sleep time data: \(data) \(writeParam)!")
            btDataModel.writeToPeripheral(writeParam)
        }
    }
}
