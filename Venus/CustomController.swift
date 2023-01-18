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
//  CustomController.swift
//  Setting
//
//  Created by waltoncob on 2016/9/29.
//  Modified by Kenneth on 2017/7/15
//  Copyright © 2016年 waltoncob. All rights reserved.
//  Copyright © 2017年 ADA. All rights reserved.

import UIKit

protocol SettingViewDelegate {
    func updateSettingTableView(birthday: String)
    func updateSettingTableView(height: String)
    func updateSettingTableView(weight: String)
    func updateSettingTableView(sleepTime: String)
    func updateSettingTableView(stepGoal: String)
}

let userStepsGoal = "7000"
let userHeight = "170"
let userWeight = "65"
//let userAge = "30"
let today: String = DateUtils.today()
let defaultBirthdayYear = Int(today.components(separatedBy: "/")[0])! - 30
let userBirthday = String(format: "%d-%@-%@", defaultBirthdayYear, today.components(separatedBy: "/")[1], today.components(separatedBy: "/")[2])
let userGenderOption: [String] = ["male",
                                  "female"]
let bandLocationOption: [String] = ["Left hand",
                                    "Right hand"]
let strideLength = "70"
let swimmingPoolSizeOption: [String] = ["25m",
                                        "50m",
                                        "25yd",
                                        "33 1/3m",
                                        "33 1/3yd"]
let lengthUnitOption: [String] = ["cm/km",
                                  "in/mi"]
let weightUnitOption: [String] = ["kg",
                                  "lbs"]
let idleAlertOption: [String] = ["ON",
                                 "OFF"]
let liftWristToViewInfoOption: [String] = ["ON",
                                           "OFF"]
let heartRateStrapModeOption: [String] = ["ON",
                                          "OFF"]
let heartRateMonitorOption: [String] = ["ON",
                                        "OFF"]
let periodicTime = "0h 30m 0s"
let oneMeasurementMaxTime = "0h 0m 25s"
let sleepTime = "21:00~10:00"
let STRIDE_LEN_FACTOR_MALE = 0.415
let STRIDE_LEN_FACTOR_FEMALE = 0.412

class CustomController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    let plistManager = PlistManager()
    let factory = SimpleCellFactory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.title = "Setting"
        var sections = [Section]()
        
        let section0 = Section(header: "")
        
        let aboutBtnContent = CellContent(title: PropertyUtils.readLocalizedProperty("action_about"), buttonColor: UIColor.blue)
        let pushToAboutListener = PushToAboutListener(controller: self, plist: plistManager)
        aboutBtnContent.add(tapListener: pushToAboutListener)
        section0.add(content: aboutBtnContent)
        //let alarmBtnContent = CellContent(title:"鬧鐘 Alarm",buttonColor:UIColor(red: 0.8, green: 0.5, blue: 0.5, alpha: 1))
        let alarmBtnContent = CellContent(title: PropertyUtils.readLocalizedProperty("action_alarm"), buttonColor: UIColor.blue)
        let pushToAlarmListener = PushToAlarmListener(controller: self, plist: plistManager)
        alarmBtnContent.add(tapListener: pushToAlarmListener)
        section0.add(content: alarmBtnContent)
        
        sections.append(section0)
        
        let section1 = Section(header: "")
        
        let stepGoalContent = CellContent(title: "step_goal", detail: userStepsGoal, addAccessory: true)
        var alertListener = AlertListener(controller:self, plist:plistManager, customAlert: changeStepGoal())
        stepGoalContent.add(tapListener: alertListener)
        section1.add(content: stepGoalContent)
        
        // Band Location (配戴位置)設定
        let bandLocationPushTable = TableContent(header: "band_location", options:bandLocationOption, factory:factory, delegate: TickTableDelegate())
        let bandLocationCellContent = CellContent(title: "band_location", push:bandLocationPushTable, detailIndex:0)
        let bandLocationPushListener = PushListener(controller:self, plist:plistManager)
        bandLocationCellContent.add(tapListener:bandLocationPushListener)
        section1.add(content:(bandLocationCellContent))
        
        
        let heightContent = CellContent(title: "height", detail: userHeight, addAccessory: true)
        alertListener = AlertListener(controller: self, plist: plistManager, customAlert: changeHeight())
        heightContent.add(tapListener: alertListener)
        section1.add(content: heightContent)
        
        let weightContent = CellContent(title: "weight", detail: userWeight, addAccessory: true)
        alertListener = AlertListener(controller: self, plist: plistManager, customAlert: changeWeight())
        weightContent.add(tapListener: alertListener)
        section1.add(content: weightContent)
        
        let birthdayContent = CellContent(title: "birthday", detail: userBirthday, addAccessory: true)
        alertListener = AlertListener(controller: self, plist: plistManager, customAlert: changeBirthday())
        birthdayContent.add(tapListener: alertListener)
        section1.add(content: birthdayContent)
        
        let genderPushTable = TableContent(header: "gender", options:userGenderOption, factory:factory, delegate: TickTableDelegate())
        let genderCellContent = CellContent(title: "gender", push:genderPushTable, detailIndex:0)
        let pushListener = PushListener(controller:self, plist:plistManager)
        genderCellContent.add(tapListener:pushListener)
        section1.add(content:(genderCellContent))
        
        let strideLenContent = CellContent(title: "stride_len", detail: strideLength, addAccessory: false)
        alertListener = AlertListener(controller: self, plist: plistManager, customAlert: nil)
        strideLenContent.add(tapListener: alertListener)
        section1.add(content: strideLenContent)
        
        let swimPoolSizePushTable = TableContent(header: "swim_pool_size", options:swimmingPoolSizeOption, factory:factory, delegate: TickTableDelegate())
        let swimPoolSizeCellContent = CellContent(title: "swim_pool_size", push:swimPoolSizePushTable, detailIndex:1)
        let swimPoolSizePushListener = PushListener(controller:self, plist:plistManager)
        swimPoolSizeCellContent.add(tapListener:swimPoolSizePushListener)
        section1.add(content:(swimPoolSizeCellContent))
        
        let lengthUnitPushTable = TableContent(header: "units_length", options:lengthUnitOption, factory:factory, delegate: TickTableDelegate())
        let lengthUnitCellContent = CellContent(title: "units_length", push:lengthUnitPushTable, detailIndex:0)
        let lenghUnitPushListener = PushListener(controller:self, plist:plistManager)
        lengthUnitCellContent.add(tapListener:lenghUnitPushListener)
        section1.add(content:(lengthUnitCellContent))
        
        let weightUnitPushTable = TableContent(header: "units_weight", options:weightUnitOption, factory:factory, delegate: TickTableDelegate())
        let weightUnitCellContent = CellContent(title: "units_weight", push:weightUnitPushTable, detailIndex:0)
        let weightUnitPushListener = PushListener(controller:self, plist:plistManager)
        weightUnitCellContent.add(tapListener:weightUnitPushListener)
        section1.add(content:(weightUnitCellContent))
        
        let idleAlertPushTable = TableContent(header: "smart_alerts_idle", options:idleAlertOption, factory:factory, delegate: TickTableDelegate())
        let idleAlertCellContent = CellContent(title: "smart_alerts_idle", push:idleAlertPushTable, detailIndex:1)
        let idleAlertPushListener = PushListener(controller:self, plist:plistManager)
        idleAlertCellContent.add(tapListener:idleAlertPushListener)
        section1.add(content:(idleAlertCellContent))
        
        let liftWristPushTable = TableContent(header: "lift_wrist_view", options:liftWristToViewInfoOption, factory:factory, delegate: TickTableDelegate())
        let liftWristCellContent = CellContent(title: "lift_wrist_view", push:liftWristPushTable, detailIndex:1)
        let liftWristPushListener = PushListener(controller:self, plist:plistManager)
        liftWristCellContent.add(tapListener:liftWristPushListener)
        section1.add(content:(liftWristCellContent))
        
        //====== new function
        let heartRateStrapPushTable = TableContent(header: "heart_rate_strap_mode", options:heartRateStrapModeOption, factory:factory, delegate: TickTableDelegate())
        let heartRateStrapCellContent = CellContent(title: "heart_rate_strap_mode", push:heartRateStrapPushTable, detailIndex:1)
        let heartRateStrapPushListener = PushListener(controller:self, plist:plistManager)
        heartRateStrapCellContent.add(tapListener:heartRateStrapPushListener)
        section1.add(content:(heartRateStrapCellContent))
        
        let heartRateStrap24PushTable = TableContent(header: "heart_rate_24hr_monitor", options:heartRateMonitorOption, factory:factory, delegate: TickTableDelegate())
        let heartRateStrap24CellContent = CellContent(title: "heart_rate_24hr_monitor", push:heartRateStrap24PushTable, detailIndex:1)
        let heartRateStrap24PushListener = PushListener(controller:self, plist:plistManager)
        heartRateStrap24CellContent.add(tapListener:heartRateStrap24PushListener)
        section1.add(content:(heartRateStrap24CellContent))
        
        
        
        /*
        let periodicContent = CellContent(title: "heart_rate_24hr_periodic_measure_time", detail: periodicTime, addAccessory: true)
        alertListener = AlertListener(controller: self, plist: plistManager, alert: change_periodic_measure_time())
        periodicContent.add(tapListener: alertListener)
        section1.add(content: periodicContent)
        
        let one_measureContent = CellContent(title: "heart_rate_24hr_one_measure_max_time", detail: oneMeasurementMaxTime, addAccessory: true)
        alertListener = AlertListener(controller: self, plist: plistManager, alert: change_one_measure_max_time())
        one_measureContent.add(tapListener: alertListener)
        section1.add(content: one_measureContent)
        */
        
        /*
        Band location
        配戴方式
        配戴方式
        */
        
        let sleep_timeContent = CellContent(title: "sleep_time", detail: sleepTime, addAccessory: true)
        alertListener = AlertListener(controller: self, plist: plistManager, customAlert: changeSleepTime())
        sleep_timeContent.add(tapListener: alertListener)
        section1.add(content: sleep_timeContent)
        
        sections.append(section1)

        let tableContent = TableContent(sections:sections, factory:factory)
        let cellContents = tableContent.getCellContents()

        plistManager.setup(cellContents:cellContents)
        print("Plist path : \(plistManager.plistPathInDocument)")
        plistManager.adjustCellContents()

        let tableview = SettingTableView(content:tableContent)
        view = tableview

        SharingManager.sharedInstance.plistManager = plistManager
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.AlreadyOpenSetting)
    }

    public func makeAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Enabling Google fit Upload", message:
            nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default){(action) in })
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default){(action) in })
        return alert
    }
    
    /*
    public func changeStepGoal() -> UIAlertController {
        let alert = UIAlertController(title: PropertyUtils.readLocalizedProperty("Change Step Goal"),
                                      message: PropertyUtils.readLocalizedProperty("Enter Step Goal"),
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Cancel"), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Submit"), style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            // self.alarmName.text = textField?.text
            // update data
            print(textField?.text as Any)
            
            self.plistManager.setCellContent(key: "step_goal", value: (textField?.text)!)
            
            let tableView = self.view as! UITableView
            tableView.reloadData()
        }))
        //self.present(alert, animated: true, completion: nil)
        return alert
    }
    */
    
    public func changeHeight() -> UIViewController {
        let vc = CustomHeightAlertVC()
        vc.settingDelegate = self
        //self.present(vc, animated: true)
        
        return vc
    }
    
    public func changeStepGoal() -> UIViewController {
        let vc = CustomStepGoalAlertVC()
        vc.settingDelegate = self
        //self.present(vc, animated: true)
        
        return vc
    }
    
    public func changeWeight() -> UIViewController {
        let vc = CustomWeightAlertVC()
        vc.settingDelegate = self
        //self.present(vc, animated: true)
        
        return vc
        /*
        let alert = UIAlertController(title: PropertyUtils.readLocalizedProperty("Change Weight"),
                                      message: PropertyUtils.readLocalizedProperty("Enter Weight"),
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Cancel"), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Submit"), style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            print(textField?.text as Any)
            self.plistManager.setCellContent(key: "weight", value: (textField?.text)!)
            let tableView = self.view as! UITableView
            tableView.reloadData()
            
        }))
        return alert
        */
    }
    
    public func changeAge() -> UIAlertController {
        let alert = UIAlertController(title: PropertyUtils.readLocalizedProperty("Change Age"),
                                      message: PropertyUtils.readLocalizedProperty("Enter Age"),
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Cancel"), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Submit"), style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            print(textField?.text as Any)
            self.plistManager.setCellContent(key: "age", value: (textField?.text)!)
            let tableView = self.view as! UITableView
            tableView.reloadData()
            
        }))
        return alert
    }
    
    public func changeStrideLength() -> UIAlertController {
        let alert = UIAlertController(title: PropertyUtils.readLocalizedProperty("Change Stride Length"),
                                      message: PropertyUtils.readLocalizedProperty("Enter Stride Length"),
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Cancel"), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Submit"), style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            print(textField?.text as Any)
            self.plistManager.setCellContent(key: "stride_len", value: (textField?.text)!)
            let tableView = self.view as! UITableView
            tableView.reloadData()
            
        }))
        return alert
    }
    
    public func change_periodic_measure_time() -> UIAlertController {
        let alert = UIAlertController(title: PropertyUtils.readLocalizedProperty("Change periodic_measure_time"),
                                      message: PropertyUtils.readLocalizedProperty("Enter Time"),
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Cancel"), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Submit"), style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            print(textField?.text as Any)
            self.plistManager.setCellContent(key: "heart_rate_24hr_periodic_measure_time", value: (textField?.text)!)
            let tableView = self.view as! UITableView
            tableView.reloadData()
            
        }))
        return alert
    }
    
    public func change_one_measure_max_time() -> UIAlertController {
        let alert = UIAlertController(title: PropertyUtils.readLocalizedProperty("Change one_measure_max_time"),
                                      message: PropertyUtils.readLocalizedProperty("Enter Time"),
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Cancel"), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Submit"), style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            print(textField?.text as Any)
            self.plistManager.setCellContent(key: "heart_rate_24hr_one_measure_max_time", value: (textField?.text)!)
            let tableView = self.view as! UITableView
            tableView.reloadData()
            
        }))
        return alert
    }
    
    public func changeBirthday() -> UIViewController {
        let vc = CustomBirthdayAlertVC()
        vc.settingDelegate = self
        //self.present(vc, animated: true)
        //let tableView = self.view as! UITableView
        //tableView.reloadData()
        return vc
        
    }
    
    public func changeSleepTime() -> UIViewController {
        let vc = CustomAlertViewController()
        vc.settingDelegate = self
        //self.present(vc, animated: true)
        
        return vc
        /*
        let alert = UIAlertController(title: PropertyUtils.readLocalizedProperty("Change Sleep Time"),
                                      message: PropertyUtils.readLocalizedProperty("Enter Time"),
                                      preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Cancel"), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: PropertyUtils.readLocalizedProperty("Submit"), style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            print(textField?.text as Any)
            self.plistManager.setCellContent(key: "sleep_time", value: (textField?.text)!)
            let tableView = self.view as! UITableView
            tableView.reloadData()
            
        }))
        return alert
        */
    }
    
    /*
    public func alarmAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Go to Alarm View", message:
            nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default){(action) in })
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default){(action) in })
        return alert
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }  
    }
    */
}

// MARK: - KenoBettingDelegate
extension CustomController: SettingViewDelegate {
    func updateSettingTableView(birthday: String) {
        self.plistManager.setCellContent(key: "birthday", value: birthday)
        let tableView = self.view as! UITableView
        tableView.reloadData()
    }
    
    func updateSettingTableView(height: String) {
        self.plistManager.setCellContent(key: "height", value: height)
        
        // 步幅
        // 男生：身高 x STRIDE_LEN_FACTOR_MALE
        // 女生：身高 x STRIDE_LEN_FACTOR_FEMALE
        // 170 x 0.415 = 70.55  無條件捨去？
        // let x = 3.7
        // let y = x.rounded() // y = 4.0. x = 3.7
        
        var strideLen: Double = 0.0
        let heightIntValue = Int(height)!
        
        if self.plistManager.getCellContent(key: "gender") == "male" {
            strideLen = Double(heightIntValue) * STRIDE_LEN_FACTOR_MALE
        } else {
            strideLen = Double(heightIntValue) * STRIDE_LEN_FACTOR_FEMALE
        }
        
        let result = Int(strideLen.rounded())
        print("strideLen=\(result)")
        self.plistManager.setCellContent(key: "stride_len", value: "\(result)")
        
        let tableView = self.view as! UITableView
        tableView.reloadData()
    }
    
    func updateSettingTableView(weight: String) {
        self.plistManager.setCellContent(key: "weight", value: weight)
        let tableView = self.view as! UITableView
        tableView.reloadData()
    }
    
    func updateSettingTableView(sleepTime: String) {
        self.plistManager.setCellContent(key: "sleep_time", value: sleepTime)
        let tableView = self.view as! UITableView
        tableView.reloadData()
    }
    
    func updateSettingTableView(stepGoal: String) {
        self.plistManager.setCellContent(key: "step_goal", value: stepGoal)
        let tableView = self.view as! UITableView
        tableView.reloadData()
    }
}
