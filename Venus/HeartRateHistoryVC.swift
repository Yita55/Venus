//
//  HeartRateHistoryVC.swift
//  Venus
//
//  Created by Kenneth on 2017/Aug/13.
//  Copyright © 2017年 ADA. All rights reserved.
//

import UIKit
import RealmSwift
import EZAlertController

struct testStruct {
    var time: String
    var heart_rate_value: Int
}

class HeartRateHistoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func refreshButtonTap(_ sender: AnyObject) {
        if btDataModel.btConnectedPeripheral == nil {
            EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"), message: PropertyUtils.readLocalizedProperty("no_device_bonded"), acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
                print("cliked OK")
                self.reloadDataThenUpdateUI()
            }
        } else {
            //====== connected device, start to sync ...
            btDataModel.isSyncAll = false
            btDataModel.queryHistoryOfHeartRateFB()
        }
    }
    
    @IBOutlet weak var lastBPMLabel: UILabel!
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var tmpList: Results<heart_rate>!
    //var heartRateList: Results<heart_rate>!
    //var testHeartRateList = [testStruct]()
    var btDataModel = BTDataModel.sharedInstance
    let rateUnitStr = PropertyUtils.readLocalizedProperty("heart_rate_unit")
    var convertedStrArray: [String] = []
    var dateHeartRateDict = [String: Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ???
        // self.edgesForExtendedLayout = []
        NotificationCenter.default.addObserver(self, selector: #selector(HeartRateHistoryVC.reloadDataThenUpdateUI), name: NSNotification.Name(rawValue: kSyncHeartRateComplete), object: nil)
        
        if btDataModel.btConnectedPeripheral == nil {
            EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"), message: PropertyUtils.readLocalizedProperty("no_device_bonded"), acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
                print("cliked OK")
                self.reloadDataThenUpdateUI()
            }
        } else {
            //====== connected device, start to sync ...
            btDataModel.isSyncAll = false
            btDataModel.queryHistoryOfHeartRateFB()
        }
        
        /*
        let item = testStruct(time: "7/12/17 11:29:00", heart_rate_value: 26)
        testHeartRateList.append(item)
        
        let item2 = testStruct(time: "7/13/17 11:29:00", heart_rate_value: 77)
        testHeartRateList.append(item2)
        
        let item3 = testStruct(time: "7/15/17 11:29:00", heart_rate_value: 26)
        testHeartRateList.append(item3)
        */
        
        //self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.navigationController?.topViewController != self {
            print("back button tapped!")
            SharingManager.sharedInstance.isBackFromHeartRateHistory = true
        }
    }
    
    // MARK: - DataSource
    // ---------------------------------------------------------------------
    // 設定表格section的列數
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return testHeartRateList.count
        return convertedStrArray.count
    }
    
    // 表格的儲存格設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var cell = tableView.dequeueReusableCell(withIdentifier: "HeartRateCell")
        //if cell == nil {
        //    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "HeartRateCell")
        //}
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeartRateCell", for: indexPath) as! HeartRateCell
        
        //cell.selectionStyle = UITableViewCellSelectionStyle.none
        //cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        let timeStr = self.convertedStrArray[indexPath.row]
        
        cell.timeLabel.text = timeStr
        cell.bpmLabel.text = "\(self.dateHeartRateDict[timeStr]!)" + " " + self.rateUnitStr
        //cell.timeLabel.text = self.heartRateList[indexPath.row].time
        //cell.bpmLabel.text = "\(self.heartRateList[indexPath.row].heart_rate_value)" + " " + self.rateUnitStr
        
        return cell
    }
    
    func reloadDataThenUpdateUI() {
        // 查詢資料
        let realm = try! Realm()
        self.tmpList = realm.objects(heart_rate.self)
        
        var timeStrArray = [String]()
        
        for i in 0..<self.tmpList.count {
            //print(self.tmpList[i].time)
            timeStrArray.append(self.tmpList[i].time)
            
            // let dictItem = [self.tmpList[i].time: self.tmpList[i].heart_rate_value]
            dateHeartRateDict[self.tmpList[i].time] = self.tmpList[i].heart_rate_value
        }

        print(dateHeartRateDict)
        
        
        var convertedArray: [Date] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        
        for dat in timeStrArray {
            let date = dateFormatter.date(from: dat)
            if let date = date {
                convertedArray.append(date)
            }
        }
        
        let ready = convertedArray.sorted(by: { $0.compare($1) == .orderedDescending })
        
        print(ready)
        
        for date in ready {
            let convertedTimeStr = dateFormatter.string(from: date)
            convertedStrArray.append(convertedTimeStr)
        }
        
        print(convertedStrArray)
        
        
        //self.heartRateList = self.tmpList.sorted(byKeyPath: "time", ascending: false)
        
        if self.convertedStrArray.count > 0 {
            let timeStr = self.convertedStrArray[0]
            
            self.lastTimeLabel.text = timeStr
            self.lastBPMLabel.text = String(format: "%d", self.dateHeartRateDict[timeStr]!)
        } else {
#if false
            self.btDataModel.insertToDB_0xFB(time: "12/12/2017 11:29:00", valueOfHeartRate: 76)
            self.btDataModel.insertToDB_0xFB(time: "12/12/2017 12:29:00", valueOfHeartRate: 87)
            self.btDataModel.insertToDB_0xFB(time: "12/12/2017 13:29:00", valueOfHeartRate: 96)
            self.btDataModel.insertToDB_0xFB(time: "01/02/2018 14:29:00", valueOfHeartRate: 66)
            self.btDataModel.insertToDB_0xFB(time: "01/02/2018 16:29:00", valueOfHeartRate: 76)
            self.btDataModel.insertToDB_0xFB(time: "01/02/2018 17:29:00", valueOfHeartRate: 87)
            self.btDataModel.insertToDB_0xFB(time: "01/01/2018 18:29:00", valueOfHeartRate: 96)
            self.btDataModel.insertToDB_0xFB(time: "01/01/2018 19:29:00", valueOfHeartRate: 66)
            self.btDataModel.insertToDB_0xFB(time: "01/02/2018 20:29:00", valueOfHeartRate: 76)
            self.btDataModel.insertToDB_0xFB(time: "12/12/2017 21:29:00", valueOfHeartRate: 99)
            self.btDataModel.insertToDB_0xFB(time: "12/12/2017 22:29:00", valueOfHeartRate: 96)
            self.btDataModel.insertToDB_0xFB(time: "12/12/2017 23:29:00", valueOfHeartRate: 66)

            self.reloadDataThenUpdateUI()
            return
#endif
        }

        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
}
