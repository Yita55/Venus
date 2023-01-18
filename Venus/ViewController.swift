//
//  ViewController.swift
//  Venus
//
//  Created by Kenneth on 20/06/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import UIKit
import CoreBluetooth
import Charts
import KDCircularProgress
import SwiftProgressHUD
import RealmSwift
import EZAlertController

class ViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var circleProgress: KDCircularProgress!
    @IBOutlet weak var stepsGoalLabel: UILabel!
    @IBOutlet weak var showKMLabel: UILabel!
    @IBOutlet weak var showKcalLabel: UILabel!
    @IBOutlet weak var stepsTextLabel: UILabel!
    @IBOutlet weak var stepUnitLabel: UILabel!
    @IBOutlet weak var kcalUnitLabel: UILabel!
    @IBOutlet weak var sleepTitleLabel: UILabel!
    @IBOutlet weak var heartRateTitleLabel: UILabel!
    @IBOutlet weak var bleBarButton: UIBarButtonItem!
    @IBOutlet weak var modeImageView: UIImageView!
    @IBOutlet weak var inBedForTimeLabel: UILabel!
    @IBOutlet weak var deepSleepTimeLabel: UILabel!
    @IBOutlet weak var lightSleepTimeLabel: UILabel!
    @IBOutlet weak var lineChartViewFirstShow: LineChartView!
    
    @IBOutlet weak var lastestHeartRateLabel: UILabel!
    @IBOutlet weak var heartRateUnitLabel: UILabel!
    
    @IBAction func goToScanDeviceView(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "BtDeviceList", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BTDevicesListViewController") as! BTDevicesListViewController
        
        vc.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(vc, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func goToHeartRateHistory(_ sender: UIButton) {
        print("goToHeartRateHistory!")
        
        let storyboard = UIStoryboard(name: "HeartRateHistory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HeartRateHistoryVC") as! HeartRateHistoryVC
        
        vc.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(vc, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)        
    }
    
    @IBAction func goToSleepHistoryView(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "SleepHistory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SleepHistoryVC") as! SleepHistoryVC
        
        vc.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(vc, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func goToStepsHistory(_ sender: UIButton) {
        print("goToStepsHistory!")
        let storyboard = UIStoryboard(name: "StepHistory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "StepHistoryVC") as! StepHistoryVC
        
        vc.hidesBottomBarWhenPushed = true
        if let stepStr = self.stepLabel.text {
            vc.totalStep = Int(stepStr)!
        }
        vc.totalDistance = self.currentTotalDistance
        
        if let cal = self.showKcalLabel.text {
            vc.totalCalorie = Int(cal)!
        }
        
        print("totalStep=\(vc.totalStep)")
        print("totalDistance=\(vc.totalDistance)")
        print("totalCalorie=\(vc.totalCalorie)")
        
        //vc.totalCalorie = 3
        self.navigationController!.pushViewController(vc, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    var debugFlag = false
    // call BTDataModel.sharedInstance will start scan device
    var btDataModel = BTDataModel.sharedInstance
    var updateTimer: Timer?
    //var showAnimateTime: Timer?
    // test data
    var chartXIndex = 0
    var i = 0
    var j = 0
    var reading_a: [Double] = [63.0, 65.0, 66.0, 68.0, 72.0, 82.0, 81.0, 83.0, 80.0, 81.0,
                               63.0, 65.0, 66.0, 68.0, 72.0, 82.0, 81.0, 83.0, 80.0, 81.0,
                               63.0, 65.0, 66.0, 68.0, 72.0, 82.0, 81.0, 83.0, 80.0, 81.0,
                               63.0, 65.0, 66.0, 68.0, 72.0, 82.0, 81.0, 83.0, 80.0, 81.0,
                               63.0, 65.0, 66.0, 68.0, 72.0, 82.0, 81.0, 83.0, 80.0, 81.0,
                               63.0, 65.0, 66.0, 68.0, 72.0, 82.0, 81.0, 83.0, 80.0, 81.0,
                               63.0, 65.0, 66.0, 68.0, 72.0, 82.0, 81.0, 83.0, 80.0, 81.0,
                               63.0, 65.0, 66.0, 68.0, 72.0, 82.0, 81.0, 83.0, 80.0, 81.0,
                               63.0, 65.0, 66.0, 68.0, 72.0, 82.0, 81.0, 83.0, 80.0, 81.0,
                               63.0, 65.0, 66.0, 68.0, 72.0, 82.0, 81.0, 83.0, 80.0, 81.0]
    var reading_b: [Double] = [5.6, 7.8, 9.9, 12.7, 5.6, 7.8, 9.9, 12.7, 5.6, 7.8, 9.9, 12.7]
    var currentAngle: Double = 0
    
    var plistManager = PlistManager()
    var strideLengthIntValue: Double = 0.0
    var heightIntValue: Int = 0
    var weightIntValue: Int = 0
    var ageIntValue: Int = 0
    var genderValue: String = ""
    let font33 = UIFont.systemFontOfSizeByScreenWidth(375.0, fontSize: 33.0)
    var flagOfInitChart: Bool = true
    var sleepList: Results<sleep>!
    var tmpSleepList: Results<sleep>!
    var heartRateList: Results<heart_rate>!
    var tmpList: Results<heart_rate>!
    
    var stepList: Results<step>!
    var tmpStepList: Results<step>!
    
    var birthdayValue = ""
    weak var iValueFormatDelegate: IValueFormatter?
    
    var sleepDataOne = [sleepDataStruct]()
    var sleepTime: String = ""
    var sleepStartTime: String = ""
    var sleepEndTime: String = ""
    var hourStr: String = PropertyUtils.readLocalizedProperty("timepicker_hour")
    var minStr: String = PropertyUtils.readLocalizedProperty("timepicker_minute")
    var unitLengthValue = ""
    
    var convertedStrArray: [String] = []
    var dateHeartRateDict = [String: Int]()
    var currentTotalDistance: Double = 0.0
    var gStepGoal: Int = 7000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.edgesForExtendedLayout = []
        //self.automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateStepUI(_:)), name: NSNotification.Name(rawValue: kNotifyStep), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateHeartRateUI(_:)), name: NSNotification.Name(rawValue: kNotifyHeartRate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.disConnectedBluetoothDevice(_:)), name: NSNotification.Name(rawValue: kDeviceDisConnected), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateModeImageToStepMode), name: NSNotification.Name(rawValue: kNotifyStepMode), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateModeImageToSwimMode), name: NSNotification.Name(rawValue: kNotifySwimMode), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.blePoweredOffHandler), name: NSNotification.Name(rawValue: kBlePowerOff), object: nil)
        //charts
        self.lineChartView.delegate = self
        iValueFormatDelegate = self
        
        let set_a: LineChartDataSet = LineChartDataSet(values:[ChartDataEntry(x: Double(0),
                                                                              y: Double(0.0))], label: "BPM")
        /*
        set_a.drawCirclesEnabled = true
        set_a.setCircleColor(UIColor.green)
        set_a.setColor(UIColor.green)
        set_a.valueTextColor = UIColor.green
        */
        set_a.drawCirclesEnabled = false
        set_a.setCircleColor(UIColor.green)
        set_a.setColor(UIColor.green)
        set_a.valueTextColor = UIColor.clear
        self.lineChartView.xAxis.labelTextColor = UIColor.clear
        self.lineChartView.leftAxis.labelTextColor = UIColor.white
        //let set_b: LineChartDataSet = LineChartDataSet(values: [ ChartDataEntry(x: Double(0),
        //                                                                        y: Double(0)) ], label: "flow")
        //set_b.drawCirclesEnabled = false
        //set_b.setColor(UIColor.green)
        //self.lineChartView.data = LineChartData(dataSets: [set_a,set_b])
        let maxLimit = ChartLimitLine(limit: 140.0)
        maxLimit.lineColor = UIColor.red
        maxLimit.valueTextColor = UIColor.red
        let minLimit = ChartLimitLine(limit: 40.0)
        
        self.lineChartView.leftAxis.axisMinimum = 0
        self.lineChartView.leftAxis.axisMaximum = 180
        
        minLimit.lineColor = UIColor.blue
        minLimit.valueTextColor = UIColor.blue
        self.lineChartView.leftAxis.addLimitLine(maxLimit)
        self.lineChartView.leftAxis.addLimitLine(minLimit)
        //self.lineChartView.xAxis.addLimitLine(maxLimit)
        //self.lineChartView.xAxis.addLimitLine(minLimit)
        self.lineChartView.data = LineChartData(dataSets: [set_a])
        self.lineChartView.legend.enabled = false
        self.lineChartView.chartDescription?.enabled = false
        self.lineChartView.chartDescription?.text = ""
        
        
        
        
        self.stepLabel.font = font33
        self.stepLabel.text = "0"
        
        self.stepsTextLabel.text = PropertyUtils.readLocalizedProperty("step")
        self.stepUnitLabel.text = PropertyUtils.readLocalizedProperty("step_unit")
        
        self.kcalUnitLabel.text = PropertyUtils.readLocalizedProperty("calorie_k_unit")
        self.sleepTitleLabel.text = PropertyUtils.readLocalizedProperty("sleep")
        self.heartRateTitleLabel.text = PropertyUtils.readLocalizedProperty("heart_rate")
        
        
        
        
        
        self.modeImageView.isHidden = true
        
        #if false
        self.writeData()
        self.testRLM()
        #endif
        
        
        self.lastestHeartRateLabel.text = "-"
        self.heartRateUnitLabel.text = PropertyUtils.readLocalizedProperty("heart_rate_unit")
        
        
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_menu_bluetooth_connected"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(shareAction(bar:)))
        
        
        self.loadHeartRateDataThenShow()
        
        
        self.unitLengthValue = "cm/km"
        print("viewdidload - self.unitLengthValue=\(self.unitLengthValue)!")
        
        
        //if self.unitLengthValue == "cm/km" {
            self.showKMLabel.text = "0" + PropertyUtils.readLocalizedProperty("distance_unit_km")
        //} else {
        //    self.showKMLabel.text = "0" + PropertyUtils.readLocalizedProperty("distance_unit_mile")
        //}
        self.loadLastStepToShow()
    }
    
    func getSleepListFromDatabase() -> Results<sleep> {
        do {
            let realm = try Realm()
            self.tmpSleepList = realm.objects(sleep.self)
            self.sleepList = self.tmpSleepList.sorted(byKeyPath: "start_time", ascending: true)
            //self.sleepList = realm.objects(sleep.self)
            //return realm.objects(sleep.self)
            return self.sleepList
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func computeDuration(sTime: String, eTime: String) -> Int {
        let dateFormatterX = DateFormatter()
        dateFormatterX.dateFormat = "yyyy/MM/dd-HH:mm:ss"
        dateFormatterX.timeZone = TimeZone(secondsFromGMT: 0)
        
        let sDate = dateFormatterX.date(from: sTime)
        let eDate = dateFormatterX.date(from: eTime)
        let components = Calendar.current.dateComponents([.year, .month, .hour, .minute, .second],
                                                         from: sDate!,
                                                         to: eDate!)
        print("computeDuration :: sTime=\(sTime) ~ eTime=\(eTime)")
        //print("year")
        //print(components.year ?? 0)
        //print("month")
        //print(components.month ?? 0)
        //print("day")
        //print(components.day ?? 0)
        //print("hour")
        print(components.hour ?? 0)
        //print("minute")
        print(components.minute ?? 0)
        //print("second")
        print(components.second ?? 0)
        
        var totalSecond: Int = 0
        
        if components.hour != 0 {
            totalSecond = components.hour! * 60 * 60
        }
        if components.minute != 0 {
            totalSecond += components.minute! * 60
        }
        if components.second != 0 {
            totalSecond += components.second!
        }
        
        return totalSecond
    }
    
    func checkDayInRange(day: Date, itemDate: String) -> Bool {
        var startRangeOfDay = Date()
        var endRangeOfDay = Date()
        
        print("checkDayInRange() :: day=\(day) itemDate=\(itemDate)  sleepStartTime=\(self.sleepStartTime) sleepEndTime=\(self.sleepEndTime)")
        
        startRangeOfDay = day.dateAt(day: day.day-1,
                                     hours: Int(self.sleepStartTime.components(separatedBy: ":")[0])!,
                                     minutes: Int(self.sleepStartTime.components(separatedBy: ":")[1])!)
        endRangeOfDay = day.dateAt(day: day.day,
                                   hours: Int(self.sleepEndTime.components(separatedBy: ":")[0])!,
                                   minutes: Int(self.sleepEndTime.components(separatedBy: ":")[1])!)
        
        let tmpformatter = DateFormatter()
        tmpformatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
        let resultOfStart = tmpformatter.string(from: startRangeOfDay)
        let resultOfEnd = tmpformatter.string(from: endRangeOfDay)
        print("range=\(resultOfStart) ~ \(resultOfEnd)")
        
        let startDateStr = resultOfStart.components(separatedBy: "-")[0]
        let endDateStr = resultOfEnd.components(separatedBy: "-")[0]
        
        if itemDate == startDateStr ||
            itemDate == endDateStr {
            return true
        }
        /*
        if itemDate >= startRangeOfDay &&
            itemDate <= endRangeOfDay {
            print("The time is between \(resultOfStart) and \(resultOfEnd)")
            return true
        }
        */
        return false
    }
    
    func loadSleepDataThenShow() {
        // todo
        // check sleep info for show , only show yesterday
        let inBedForTime: String = UserDefaults.standard.string(forKey: UserDefaultsKey.InBedForTime)!
        let deepSleepTime: String = UserDefaults.standard.string(forKey: UserDefaultsKey.DeepSleepTime)!
        let lightSleepTime: String = UserDefaults.standard.string(forKey: UserDefaultsKey.LightSleepTime)!
        let sleepDate: String = UserDefaults.standard.string(forKey: UserDefaultsKey.SleepDate)!
        
        print("inBedForTime=\(inBedForTime)!")
        print("deepSleepTime=\(deepSleepTime)!")
        print("lightSleepTime=\(lightSleepTime)!")
        print("sleepDate=\(sleepDate)!")
        
        if sleepDate != "0" {
            let yesterday = Date().yesterday
            let yesterdayStr = String(format: "%04i/%02i/%02i", yesterday.year, yesterday.month, yesterday.day)
            print("yesterday=\(yesterday) yesterdayStr=\(yesterdayStr)")
            
            // 1116_2017, modify, check sleep time ...
            // yesterday=2017-11-15 08:17:13 +0000 yesterdayStr=2017/11/15
            // sleepDate=2017/11/16
            print("sleepDate=\(sleepDate)")
            let today = Date()
            if checkDayInRange(day: today, itemDate: sleepDate) {
                if inBedForTime != "0" {
                    let tmpInBedStr = inBedForTime.components(separatedBy: "-")
                    
                    let forShowInBedStr = tmpInBedStr[0] + PropertyUtils.readLocalizedProperty("timepicker_hour") + tmpInBedStr[1] + PropertyUtils.readLocalizedProperty("timepicker_minute") + tmpInBedStr[2]
                    
                    self.inBedForTimeLabel.text = forShowInBedStr
                }
                if deepSleepTime != "0" {
                    let tmpDeepStr = deepSleepTime.components(separatedBy: "-")
                    let forShowDeepStr = tmpDeepStr[0] + PropertyUtils.readLocalizedProperty("timepicker_hour") + tmpDeepStr[1] + PropertyUtils.readLocalizedProperty("timepicker_minute")
                    
                    self.deepSleepTimeLabel.text = PropertyUtils.readLocalizedProperty("sleep_deep") + ": " + forShowDeepStr
                }
                if lightSleepTime != "0" {
                    let tmplight = lightSleepTime.components(separatedBy: "-")
                    let forShowLightStr = tmplight[0] + PropertyUtils.readLocalizedProperty("timepicker_hour") + tmplight[1] + PropertyUtils.readLocalizedProperty("timepicker_minute")
                    
                    self.lightSleepTimeLabel.text = PropertyUtils.readLocalizedProperty("sleep_light") + ": " + forShowLightStr
                }
            } else {
                self.inBedForTimeLabel.text = "0" + PropertyUtils.readLocalizedProperty("timepicker_hour") + "0" + PropertyUtils.readLocalizedProperty("timepicker_minute") + "00:00~00:00"
                self.deepSleepTimeLabel.text = PropertyUtils.readLocalizedProperty("sleep_deep") + ": " + "0" + PropertyUtils.readLocalizedProperty("timepicker_hour") + "0" + PropertyUtils.readLocalizedProperty("timepicker_minute")
                self.lightSleepTimeLabel.text = PropertyUtils.readLocalizedProperty("sleep_light") + ": " + "0" + PropertyUtils.readLocalizedProperty("timepicker_hour") + "0" + PropertyUtils.readLocalizedProperty("timepicker_minute")
            }
        } else {
            if inBedForTime != "0" {
                
                let tmpInBedStr = inBedForTime.components(separatedBy: "-")
                
                let forShowInBedStr = tmpInBedStr[0] + PropertyUtils.readLocalizedProperty("timepicker_hour") + tmpInBedStr[1] + PropertyUtils.readLocalizedProperty("timepicker_minute") + tmpInBedStr[2]
                
                self.inBedForTimeLabel.text = forShowInBedStr
            }
            if deepSleepTime != "0" {
                let tmpDeepStr = deepSleepTime.components(separatedBy: "-")
                let forShowDeepStr = tmpDeepStr[0] + PropertyUtils.readLocalizedProperty("timepicker_hour") + tmpDeepStr[1] + PropertyUtils.readLocalizedProperty("timepicker_minute")
                

                self.deepSleepTimeLabel.text = PropertyUtils.readLocalizedProperty("sleep_deep") + ": " + forShowDeepStr
            }
            if lightSleepTime != "0" {
                let tmplight = lightSleepTime.components(separatedBy: "-")
                let forShowLightStr = tmplight[0] + PropertyUtils.readLocalizedProperty("timepicker_hour") + tmplight[1] + PropertyUtils.readLocalizedProperty("timepicker_minute")
                
                self.lightSleepTimeLabel.text = PropertyUtils.readLocalizedProperty("sleep_light") + ": " + forShowLightStr
            }
        }
    }
    
    func loadLastStepToShow() {
        let lastStep = UserDefaults.standard.string(forKey: UserDefaultsKey.LastStep)!
        let lastCalorie = UserDefaults.standard.string(forKey: UserDefaultsKey.LastCalorie)!
        let lastDistance = UserDefaults.standard.string(forKey: UserDefaultsKey.LastDistance)!
        let lastStepIntValue = Int(lastStep)!
        print("loadLastStepToShow :: lastStepIntValue=\(lastStepIntValue) calorie=\(lastCalorie) lastDistance=\(lastDistance)!")
        
        self.stepLabel.text = "\(lastStep)"
        self.showKcalLabel.text = "\(lastCalorie)"
        
        // if lastDistance == "0" {
            self.showKMLabel.text = lastDistance + PropertyUtils.readLocalizedProperty("distance_unit_km")
        // } else {
            // self.showKMLabel.text = lastDistance + PropertyUtils.readLocalizedProperty("distance_unit_km")
        // }
        
        self.currentAngle = Double((lastStepIntValue * 360 ) / self.gStepGoal)
        
        if self.currentAngle > 360 {
            self.currentAngle = 360
        }
        if self.debugFlag {
            print("loadLastStepToShow() - currentAngle=\(self.currentAngle)")
        }
        self.circleProgress.angle = self.currentAngle
    }
    
    func loadStepDateThenShow() {
        let today = DateUtils.today()

        /*
        步數是要記住上次離開 app 前的步數
        所以你之前已經有 100 步的話
        即使沒有連線
        進入 app 也是要有 100 步
        但是如果已經「換天」了
        app 也還沒有連線的話
        就要清回 0 步
    
        例如
        Last Step Time: 2017/10/13 AM10:00
        Last Step: 100 步
    
    
        如果今天 10/14 都還沒有跟手環連線
        就清成 0
        邏輯是這樣
        先檢查 last step time 是否為今天
        是今天的話，就把 last step 拿出來 show
        如果不是今天
        就填 0
        點 history 因為還沒連線
        所以一定是 0
        */
        
        // 查詢資料
        let realm = try! Realm()
        self.tmpStepList = realm.objects(step.self)
        //SharingManager.sharedInstance.currentStepListCount = self.tmpStepList.count
        self.stepList = self.tmpStepList.sorted(byKeyPath: "start_time", ascending: false)
        
        if self.stepList.count > 0 {
            // check today data
            // if today have data => show
            // else do nothing
            // updateChartUseDBData()
            let firstItem = self.stepList[0]
            print("loadStepDateThenShow() - startTime=\(firstItem.start_time)")
            
            let firstStartTime = firstItem.start_time
            let firstDate = firstStartTime.components(separatedBy: "-")[0]
            
            print("loadStepDateThenShow() - firstDate=\(firstDate)")
            print("loadStepDateThenShow() - today=\(today)")
            print("loadStepDateThenShow() - stepCount=\(firstItem.step_count)")
            if firstDate == today {
                let step = Double(firstItem.step_count)
                let calorie = firstItem.step_calorie
                
                self.stepLabel.text = "\(firstItem.step_count)"
                self.showKcalLabel.text = "\(calorie)"
                
                let distance_KM: Double = self.strideLengthIntValue * step / 100 / 1000
                let distance_MILE: Double = self.strideLengthIntValue * step / 100 / 1000 * 0.621
                
                if self.unitLengthValue == "cm/km" {
                    self.currentTotalDistance = distance_KM
                    let distanceStr: String = String(format: "%.1f", distance_KM)
                    self.showKMLabel.text = distanceStr + PropertyUtils.readLocalizedProperty("distance_unit_km")
                } else {
                    self.currentTotalDistance = distance_MILE
                    let distanceStr: String = String(format: "%.1f", distance_MILE)
                    self.showKMLabel.text = distanceStr + PropertyUtils.readLocalizedProperty("distance_unit_mile")
                }
                
                self.currentAngle = Double((step * 360 ) / Double(self.gStepGoal))
                
                if self.currentAngle > 360 {
                    self.currentAngle = 360
                }
                if self.debugFlag {
                    print("loadStepDateThenShow() - currentAngle=\(self.currentAngle)")
                }
                self.circleProgress.angle = self.currentAngle
                
            } else {
                
                self.stepLabel.text = "0"
            }
            
        } else {
            // do nothing
            self.showKcalLabel.text = "0"
            self.currentAngle = 360
        }
    }
    
    func loadHeartRateDataThenShow() {
        // 查詢資料
        let realm = try! Realm()
        self.tmpList = realm.objects(heart_rate.self)
        dateHeartRateDict.removeAll()
        convertedStrArray.removeAll()
        //self.heartRateList = self.tmpList.sorted(byKeyPath: "time", ascending: false)
        
        var timeStrArray = [String]()
        
        for i in 0..<self.tmpList.count {
            timeStrArray.append(self.tmpList[i].time)
            dateHeartRateDict[self.tmpList[i].time] = self.tmpList[i].heart_rate_value
            //print("time=\(self.tmpList[i].time)")
        }
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
        
        for date in ready {
            let convertedTimeStr = dateFormatter.string(from: date)
            convertedStrArray.append(convertedTimeStr)
            //print("loadHeartRateDataThenShow - \(convertedTimeStr)!")
        }
        
        
        
        //if self.heartRateList.count > 0 {
        if self.convertedStrArray.count > 0 {
            updateChartUseDBData()
            self.lineChartView.isHidden = true
            self.lineChartViewFirstShow.isHidden = false
        } else {
            self.lineChartView.isHidden = false
            self.lineChartViewFirstShow.isHidden = true
        }
    }
    
    func bleButtonPressed() {
        let storyboard = UIStoryboard(name: "BtDeviceList", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BTDevicesListViewController") as! BTDevicesListViewController
        
        vc.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(vc, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    //func shareAction(bar:UIBarButtonItem){
    //}
    
    // add point
    func updateCounter() {
        /*
        self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(i), y: reading_a[j]),
                                          dataSetIndex: 0)
        // 0 -> 指 set_a
        //self.lineChartView.data?.addEntry(ChartDataEntry(x:Double(i) ,
        //                                                 y:reading_b[i] ), dataSetIndex: 1)
        self.lineChartView.notifyDataSetChanged()
        self.lineChartView.moveViewToX(Double(i))
        i = i + 1
        j = j + 1
        if j == reading_a.count {
            j = 0
        }
        // self.stepLabel.text = "\(reading_a[j])"
        */
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotifyHeartRate),
                                        object: self,
                                        userInfo: ["HeateRate": UInt16(littleEndian: 78)])
    }

    /*
    func runAnimate() {
        circleProgress.animate(fromAngle: 0, toAngle: 360, duration: 5) { completed in
            if completed {
                //print("animation stopped, completed")
            } else {
                //print("animation stopped, was interrupted")
            }
        }
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if btDataModel.currentMode == 1 {
            self.modeImageView.isHidden = false
            self.modeImageView.image = UIImage(named: "ic_walk_mode")
        } else if btDataModel.currentMode == 2 {
            self.modeImageView.isHidden = false
            self.modeImageView.image = UIImage(named: "ic_swim_mode")
        } else {
            self.modeImageView.isHidden = true
        }
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.AlreadyOpenSetting) == true {
            if let plistManager = SharingManager.sharedInstance.plistManager {
                self.plistManager = plistManager
                
                print(plistManager.getCellContent(key: "step_goal"))
                print(plistManager.getCellContent(key: "height"))
                print(plistManager.getCellContent(key: "weight"))
                
                let age = UserDefaults.standard.string(forKey: UserDefaultsKey.Age)!
                self.ageIntValue = Int(age)!
                
                print(plistManager.getCellContent(key: "stride_len"))
                self.heightIntValue = Int(plistManager.getCellContent(key: "height"))!
                self.weightIntValue = Int(plistManager.getCellContent(key: "weight"))!
                
                self.genderValue = plistManager.getCellContent(key: "gender")
                self.stepsGoalLabel.text = "/ " + plistManager.getCellContent(key: "step_goal")
                self.gStepGoal = Int(plistManager.getCellContent(key: "step_goal"))!
                self.strideLengthIntValue = Double(plistManager.getCellContent(key: "stride_len"))!
                
                self.sleepTime = plistManager.getCellContent(key: "sleep_time")
                self.sleepStartTime = self.sleepTime.components(separatedBy: "~")[0]
                self.sleepEndTime = self.sleepTime.components(separatedBy: "~")[1]
                print(self.sleepTime)
                
                self.unitLengthValue = self.plistManager.getCellContent(key: "units_length")
                print(self.unitLengthValue)
            }
        }
        else {
            print("First open!")
            if self.plistManager.openPlist() == true {
                print("plist openPlist == true!")
                print(self.plistManager.getCellContent(key: "step_goal"))
                print(self.plistManager.getCellContent(key: "height"))
                print(self.plistManager.getCellContent(key: "weight"))
                
                print(self.plistManager.getCellContent(key: "stride_len"))
                
                if self.plistManager.getCellContent(key: "height") == "" {
                    self.heightIntValue = 0
                } else {
                   self.heightIntValue = Int(self.plistManager.getCellContent(key: "height"))!
                }
                self.weightIntValue = Int(self.plistManager.getCellContent(key: "weight"))!
                
                let age = UserDefaults.standard.string(forKey: UserDefaultsKey.Age)!
                self.ageIntValue = Int(age)!
                
                print("age=\(self.ageIntValue)")
                
                self.genderValue = self.plistManager.getCellContent(key: "gender")
                self.stepsGoalLabel.text = "/ " + self.plistManager.getCellContent(key: "step_goal")
                self.gStepGoal = Int(self.plistManager.getCellContent(key: "step_goal"))!
                self.strideLengthIntValue = Double(self.plistManager.getCellContent(key: "stride_len"))!
                self.sleepTime = self.plistManager.getCellContent(key: "sleep_time")
                self.sleepStartTime = self.sleepTime.components(separatedBy: "~")[0]
                self.sleepEndTime = self.sleepTime.components(separatedBy: "~")[1]
                print(self.sleepTime)
                
                self.unitLengthValue = self.plistManager.getCellContent(key: "units_length")
                print(self.unitLengthValue)
            }
            else {
                let stepGoal = UserDefaults.standard.string(forKey: UserDefaultsKey.StepsGoal)!
                let height = UserDefaults.standard.string(forKey: UserDefaultsKey.Height)!
                let weight = UserDefaults.standard.string(forKey: UserDefaultsKey.Weight)!
                let age = UserDefaults.standard.string(forKey: UserDefaultsKey.Age)!
                let strideLength = UserDefaults.standard.string(forKey: UserDefaultsKey.StrideLength)!
                print("stepGoal=\(String(describing: stepGoal))")
                print("height=\(String(describing: height))")
                print("weight=\(String(describing: weight))")
                print("age=\(String(describing: age))")
                print("strideLength=\(String(describing: strideLength))")
                
                self.heightIntValue = Int(height)!
                self.weightIntValue = Int(weight)!
                self.ageIntValue = Int(age)!
                self.genderValue = "male"
                self.stepsGoalLabel.text = "/ " + stepGoal
                self.strideLengthIntValue = Double(strideLength)!
                self.sleepTime = "21:00~10:00"
                self.sleepStartTime = "21:00"
                self.sleepEndTime = "10:00"
                
                self.unitLengthValue = "cm/km"
                print(self.unitLengthValue)
            }
        }
        
        // updateTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        
        circleProgress.startAngle = 270
        circleProgress.progressThickness = 0.2
        circleProgress.trackThickness = 0.2
        circleProgress.clockwise = true
        circleProgress.gradientRotateSpeed = 2
        circleProgress.roundedCorners = false
        circleProgress.glowMode = .forward
        circleProgress.glowAmount = 0.9
        //circleProgress.set(colors: UIColor.cyan ,UIColor.white, UIColor.magenta, UIColor.white, UIColor.orange)
        circleProgress.set(colors: UIColor(red: 5/255, green: 170/255, blue: 251/255, alpha: 1))
        /*
        circleProgress.animate(fromAngle: 0, toAngle: 360, duration: 5) { completed in
            if completed {
                print("animation stopped, completed")
                self.showAnimateTime = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(self.runAnimate), userInfo: nil, repeats: true)
            } else {
                print("animation stopped, was interrupted")
            }
        }
        */
        if btDataModel.btAvailable == true {
            if btDataModel.btConnectedPeripheral != nil {
                btDataModel.startStepHeartRateNotify()
                
                let button: UIButton = UIButton.init(type: .custom)
                //set image for button
                button.setImage(UIImage(named: "ic_menu_bluetooth_connected"), for: .normal)
                //add function for button
                button.addTarget(self, action: #selector(ViewController.bleButtonPressed), for: .touchUpInside)
                //set frame
                button.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
                
                let barButton = UIBarButtonItem(customView: button)
                //assign button to navigationbar
                self.navigationItem.rightBarButtonItem = barButton
                
            } else {
                
                let button: UIButton = UIButton.init(type: .custom)
                //set image for button
                button.setImage(UIImage(named: "ic_bluetooth_white"), for: .normal)
                //add function for button
                button.addTarget(self, action: #selector(ViewController.bleButtonPressed), for: .touchUpInside)
                //set frame
                button.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
                
                let barButton = UIBarButtonItem(customView: button)
                //assign button to navigationbar
                self.navigationItem.rightBarButtonItem = barButton
            }
        }
        
        
        print("unitLengthValue=\(self.unitLengthValue)!")
        /*
        if self.unitLengthValue == "cm/km" {
            self.showKMLabel.text = "0" + PropertyUtils.readLocalizedProperty("distance_unit_km")
        } else {
            self.showKMLabel.text = "0" + PropertyUtils.readLocalizedProperty("distance_unit_mile")
        }
        */
        
        self.loadSleepDataThenShow()
        
        
        if SharingManager.sharedInstance.isBackFromHeartRateHistory == true {
            print("isBackFromHeartRateHistory=true, reload heart rate!")
            self.loadHeartRateDataThenShow()
            SharingManager.sharedInstance.isBackFromHeartRateHistory = false
        } else {
            print("isBackFromHeartRateHistory=false, Do not reload heart rate!")
        }
        
        if SharingManager.sharedInstance.isBackFromStepHistory == true {
            print("isBackFromStepHistory=true, reload step!")
            //self.loadLastStepToShow()
            //???
            SharingManager.sharedInstance.isBackFromStepHistory = false
        } else {
            print("isBackFromStepHistory=false, Do not reload step!")
        }
        
        

        if btDataModel.currentMode == 0 {
            self.loadLastStepToShow()
#if false
            // no connection
            // check ViewController
            if self.tmpList.count != SharingManager.sharedInstance.currentStepListCount &&
                SharingManager.sharedInstance.currentStepListCount != 0 {
                self.loadLastStepToShow()
            } else {
                // ???
            }
#endif
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateTimer?.invalidate()
        updateTimer = nil
        //showAnimateTime?.invalidate()
        //showAnimateTime = nil
        super.viewWillDisappear(animated)
    }
    
    func updateStepUI(_ notification: Notification) {
        if debugFlag {
            print("updateStepUI()!")
        }
        let stepValue = (notification as NSNotification).userInfo?["StepValue"] as! UInt32
        let stepNumber = Double(stepValue)
        let calorieValue = (notification as NSNotification).userInfo?["StepCalorie"] as! UInt32
        let calorieNumber = Int(calorieValue)
        if debugFlag {
            print("updateStepUI :: stepNumber=\(stepNumber)")
            print("updateStepUI :: calorieNumber=\(calorieNumber)")
        }
        
        DispatchQueue.main.async(execute: {
            self.stepLabel.text = "\(Int(stepValue))"
            UserDefaults.standard.set("\(Int(stepValue))", forKey: UserDefaultsKey.LastStep)
            
            if self.unitLengthValue == "cm/km" {
                //let distance_M = self.strideLengthIntValue * stepNumber / 100
                let distance_KM: Double = self.strideLengthIntValue * stepNumber / 100 / 1000
                let distanceStr: String = String(format: "%.1f", distance_KM)
                //if distance_M > 1000 {
                self.showKMLabel.text = distanceStr + PropertyUtils.readLocalizedProperty("distance_unit_km")
                self.currentTotalDistance = distance_KM
                UserDefaults.standard.set(distanceStr, forKey: UserDefaultsKey.LastDistance)
                //} else {
                //    self.showKMLabel.text = "\(distance_M)" + PropertyUtils.readLocalizedProperty("distance_unit_m")
                //}
            } else {
                //let distance_M = self.strideLengthIntValue * stepNumber / 100
                let distance_KM: Double = self.strideLengthIntValue * stepNumber / 100 / 1000 * 0.621
                let distanceStr: String = String(format: "%.1f", distance_KM)
                //if distance_M > 1000 {
                self.showKMLabel.text = distanceStr + PropertyUtils.readLocalizedProperty("distance_unit_mile")
                self.currentTotalDistance = distance_KM
                UserDefaults.standard.set(distanceStr, forKey: UserDefaultsKey.LastDistance)
                //} else {
                //    self.showKMLabel.text = "\(distance_M)" + PropertyUtils.readLocalizedProperty("distance_unit_m")
                //}
            }
            
            
            
            
            /*
            let calorie = CalcUtils.calcStepsCalorie(steps: stepNumber,
                                                     height: self.heightIntValue,
                                                     weight: self.weightIntValue,
                                                     gender: self.genderValue,
                                                     age: self.ageIntValue,
                                                     stepState: 0)
            */
            self.showKcalLabel.text = "\(calorieNumber)"
            UserDefaults.standard.set("\(calorieNumber)", forKey: UserDefaultsKey.LastCalorie)

            self.currentAngle = Double((stepNumber * 360 ) / Double(self.gStepGoal))
            
            if self.currentAngle > 360 {
                self.currentAngle = 360
            }
            if self.debugFlag {
                print("currentAngle=\(self.currentAngle)")
            }
            self.circleProgress.angle = self.currentAngle
        })
    }
    
    func initChart(x: Double, y: Double) {
        let set_a: LineChartDataSet = LineChartDataSet(values:[ChartDataEntry(x: x, y: y)], label: "BPM")
        set_a.drawCirclesEnabled = true
        set_a.setCircleColor(UIColor.green)
        set_a.setColor(UIColor.green)
        set_a.valueTextColor = UIColor.green
        
        //set_a.drawCirclesEnabled = false
        //set_a.setCircleColor(UIColor.green)
        //set_a.setColor(UIColor.green)
        //set_a.valueTextColor = UIColor.clear
        self.lineChartView.xAxis.labelTextColor = UIColor.clear
        self.lineChartView.leftAxis.labelTextColor = UIColor.white
        //let set_b: LineChartDataSet = LineChartDataSet(values: [ ChartDataEntry(x: Double(0),
        //                                                                        y: Double(0)) ], label: "flow")
        //set_b.drawCirclesEnabled = false
        //set_b.setColor(UIColor.green)
        //self.lineChartView.data = LineChartData(dataSets: [set_a,set_b])
        let maxLimit = ChartLimitLine(limit: 140.0)
        maxLimit.lineColor = UIColor.red
        maxLimit.valueTextColor = UIColor.red
        let minLimit = ChartLimitLine(limit: 40.0)
        
        self.lineChartView.leftAxis.axisMinimum = 0
        self.lineChartView.leftAxis.axisMaximum = 180
        
        minLimit.lineColor = UIColor.blue
        minLimit.valueTextColor = UIColor.blue
        self.lineChartView.leftAxis.addLimitLine(maxLimit)
        self.lineChartView.leftAxis.addLimitLine(minLimit)
        //self.lineChartView.xAxis.addLimitLine(maxLimit)
        //self.lineChartView.xAxis.addLimitLine(minLimit)
        self.lineChartView.data = LineChartData(dataSets: [set_a])
        self.lineChartView.legend.enabled = false
        self.lineChartView.chartDescription?.enabled = false
        self.lineChartView.chartDescription?.text = ""
        
        _ = self.lineChartView.data?.setValueFormatter(self.iValueFormatDelegate)
    }
    
    func updateChartUseDBData() {
        //var loopCount = self.heartRateList.count
        var loopCount = self.convertedStrArray.count
        
        if loopCount > 10 {
            loopCount = 10
        }
        
        var tmpHeartRateList = [testStruct]()
        
        for i in 0..<loopCount {
            let item = testStruct(time: self.convertedStrArray[i],
                                  heart_rate_value: self.dateHeartRateDict[self.convertedStrArray[i]]!)
            tmpHeartRateList.append(item)
        }
        
        tmpHeartRateList = tmpHeartRateList.reversed()
        //self.lineChartViewFirstShow.lineData?.clearValues()
        let set_a: LineChartDataSet = LineChartDataSet(values:[ChartDataEntry(x: Double(0), y: Double(tmpHeartRateList[0].heart_rate_value))], label: "BPM")
        set_a.drawCirclesEnabled = true
        set_a.setCircleColor(UIColor.green)
        set_a.setColor(UIColor.green)
        set_a.valueTextColor = UIColor.green
        self.lineChartView.xAxis.labelTextColor = UIColor.clear
        self.lineChartView.leftAxis.labelTextColor = UIColor.white
        let maxLimit = ChartLimitLine(limit: 140.0)
        maxLimit.lineColor = UIColor.red
        maxLimit.valueTextColor = UIColor.red
        let minLimit = ChartLimitLine(limit: 40.0)
        self.lineChartViewFirstShow.leftAxis.axisMinimum = 0
        self.lineChartViewFirstShow.leftAxis.axisMaximum = 180
        minLimit.lineColor = UIColor.blue
        minLimit.valueTextColor = UIColor.blue
        self.lineChartViewFirstShow.leftAxis.addLimitLine(maxLimit)
        self.lineChartViewFirstShow.leftAxis.addLimitLine(minLimit)
        self.lineChartViewFirstShow.data = LineChartData(dataSets: [set_a])
        self.lineChartViewFirstShow.legend.enabled = false
        self.lineChartViewFirstShow.chartDescription?.enabled = false
        self.lineChartViewFirstShow.chartDescription?.text = ""
        
        self.lastestHeartRateLabel.text = "\(tmpHeartRateList[0].heart_rate_value)"
        
        for i in 1..<loopCount {
            print(tmpHeartRateList[i].heart_rate_value)
            // create chart
            _ = self.lineChartViewFirstShow.data?.setValueFormatter(self.iValueFormatDelegate)
            self.lineChartViewFirstShow.data?.addEntry(ChartDataEntry(x: Double(i), y: Double(tmpHeartRateList[i].heart_rate_value)),
                                              dataSetIndex: 0)
            self.lineChartViewFirstShow.setVisibleXRange(minXRange: Double(1), maxXRange: Double(1000))
            self.lineChartViewFirstShow.setVisibleXRangeMaximum(9)
            self.lineChartViewFirstShow.notifyDataSetChanged()
            self.lineChartViewFirstShow.moveViewToX(Double(i))
            
            if i == (loopCount-1) {
                self.lastestHeartRateLabel.text = "\(tmpHeartRateList[i].heart_rate_value)"
                self.chartXIndex = loopCount
            }
        }
        
        //self.chartXIndex = 0
    }
    
    func updateHeartRateUI(_ notification: Notification) {
        if debugFlag {
            print("updateHeartRateUI()!")
        }
        let heartRateValue = (notification as NSNotification).userInfo?["HeateRate"] as! UInt16
        let heartRateNumber = Int(heartRateValue)
        if debugFlag {
            print("updateHeartRateUI :: HeartRateNumber=\(heartRateNumber)")
        }
        self.lastestHeartRateLabel.text = "\(heartRateNumber)"
        
        if self.convertedStrArray.count > 0 {
            DispatchQueue.main.async(execute: {
                self.lineChartView.isHidden = true
                self.lineChartViewFirstShow.isHidden = false

                
                //self.lineChartViewFirstShow.lineData?.clearValues()
                //self.lineChartViewFirstShow.notifyDataSetChanged()
                
                print("self.convertedStrArray.count > 0, self.chartXIndex=\(self.chartXIndex) \(heartRateNumber)")
                //_ = self.lineChartViewFirstShow.data?.setValueFormatter(self.iValueFormatDelegate)
                self.lineChartViewFirstShow.data?.addEntry(ChartDataEntry(x: Double(self.chartXIndex), y: Double(heartRateNumber)),
                                                  dataSetIndex: 0)
                if self.convertedStrArray.count > 10 {
                    self.lineChartViewFirstShow.data?.removeEntry(xValue: 0, dataSetIndex: 0)
                }
                
                self.chartXIndex = self.chartXIndex + 1
                self.lineChartViewFirstShow.setVisibleXRange(minXRange: Double(1), maxXRange: Double(1000))
                self.lineChartViewFirstShow.setVisibleXRangeMaximum(9)
                self.lineChartViewFirstShow.notifyDataSetChanged()
                self.lineChartViewFirstShow.moveViewToX(Double(self.chartXIndex))
            })
        } else {

            DispatchQueue.main.async(execute: {
                /*
                if self.lineChartView.isHidden == true {
                    self.lineChartView.isHidden = false
                }
                if self.lineChartViewFirstShow.isHidden == false {
                    self.lineChartViewFirstShow.isHidden = true
                }
                */
                self.lineChartView.isHidden = false
                self.lineChartViewFirstShow.isHidden = true
                
                if self.flagOfInitChart == true {
                    print("flagOfInitChart = true")
                    self.flagOfInitChart = false
                    self.initChart(x: Double(self.chartXIndex), y: Double(heartRateNumber))
                    self.chartXIndex = self.chartXIndex + 1
                } else {
                    _ = self.lineChartView.data?.setValueFormatter(self.iValueFormatDelegate)
                    
                    print("chartXIndex = \(self.chartXIndex)")
                    self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(self.chartXIndex), y: Double(heartRateNumber)),
                                                      dataSetIndex: 0)
                    self.chartXIndex = self.chartXIndex + 1
                    // 0 -> 指 set_a
                    //self.lineChartView.data?.addEntry(ChartDataEntry(x:Double(i) ,
                    //                                                 y:reading_b[i] ), dataSetIndex: 1)
                    self.lineChartView.setVisibleXRange(minXRange: Double(1), maxXRange: Double(1000))
                    self.lineChartView.setVisibleXRangeMaximum(9)
                    self.lineChartView.notifyDataSetChanged()
                    self.lineChartView.moveViewToX(Double(self.chartXIndex))
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scan" {
            // Set this contoller as scanner delegate
//            let nc                = segue.destination as! UINavigationController
//            let controller        = nc.childViewControllerForStatusBarHidden as! NORScannerViewController
//            controller.filterUUID = hrServiceUUID
//            controller.delegate   = self
        }
    }
}

extension ViewController: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let dotIntValue = Int(value)
        
        return "\(dotIntValue)"
    }
}

extension ViewController {
    
    func blePoweredOffHandler() {
        DispatchQueue.main.async(execute: {
            
            self.modeImageView.isHidden = true
            
            let button: UIButton = UIButton.init(type: .custom)
            //set image for button
            button.setImage(UIImage(named: "ic_bluetooth_white"), for: .normal)
            //add function for button
            button.addTarget(self, action: #selector(ViewController.bleButtonPressed), for: .touchUpInside)
            //set frame
            button.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
            
            let barButton = UIBarButtonItem(customView: button)
            //assign button to navigationbar
            self.navigationItem.rightBarButtonItem = barButton
            
            let deviceName: String = UserDefaults.standard.string(forKey: UserDefaultsKey.DeviceName)!
            
            if deviceName != "VNS_12345" {
                EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"), message: String(format: PropertyUtils.readLocalizedProperty("has been disconnected"), deviceName), acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
                    print("cliked OK")
                    UserDefaults.standard.set("VNS_12345", forKey: UserDefaultsKey.DeviceName)
                }
            }
            
        })
    }
    
    func disConnectedBluetoothDevice(_ notification: Notification) {
        guard let peripheralName = (notification as NSNotification).userInfo?["PeripheralName"] else {
            return
        }
        print("ViewController - disConnectedBluetoothDevice :: peripheralName=\(peripheralName)")
        // update mode Image
        DispatchQueue.main.async(execute: {
            self.modeImageView.isHidden = true
            
            let button: UIButton = UIButton.init(type: .custom)
            //set image for button
            button.setImage(UIImage(named: "ic_bluetooth_white"), for: .normal)
            //add function for button
            button.addTarget(self, action: #selector(ViewController.bleButtonPressed), for: .touchUpInside)
            //set frame
            button.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
            
            let barButton = UIBarButtonItem(customView: button)
            //assign button to navigationbar
            self.navigationItem.rightBarButtonItem = barButton
            
            
            let deviceName: String = UserDefaults.standard.string(forKey: UserDefaultsKey.DeviceName)!
            
            if deviceName != "VNS_12345" {
                EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"), message: String(format: PropertyUtils.readLocalizedProperty("has been disconnected"), deviceName), acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
                    print("cliked OK")
                    UserDefaults.standard.set("VNS_12345", forKey: UserDefaultsKey.DeviceName)
                }
            }
            
        })
    }
    
    func updateModeImageToStepMode() {
        print("ViewController - updateModeImageToStepMode!")
        
        // update mode Image
        DispatchQueue.main.async(execute: {
            self.modeImageView.isHidden = false
            self.modeImageView.image = UIImage(named: "ic_walk_mode")
        })
    }
    
    func updateModeImageToSwimMode() {
        print("ViewController - updateModeImageToSwimMode!")
        
        // update mode Image
        DispatchQueue.main.async(execute: {
            self.modeImageView.isHidden = false
            self.modeImageView.image = UIImage(named: "ic_swim_mode")
        })
    }
    
    #if false
    func writeData() {
        let realm = try! Realm()
        let heartRate = heart_rate()
        
        user.name = "Sam"
        user.age = 40
        user.address = "Taipei"
        
        try! realm.write {
            realm.add(user)
        }
    }
    
    func readResults() {
        let realm = try! Realm()
        let users = realm.objects(RLM_User.self) // get users:Type is Results<RLM_User>
        // Results<RLM_User>
        // Results本身是一個陣列，裡面放的是RLM_User的物件
        if users.count > 0 {
            print(users[0].name)
        }
    }
    
    // realm.add(xxx,update:true)的用法其實是資料不存在是會新增。而資料存在時會更新。
    func updateData() {
        let realm = try! Realm()
        if let user = realm.objects(RLM_User.self).filter("name = 'Sam'").first {
            user.age = 20
            try! realm.write {
                realm.add(user,update:true)
            }
        }
    }
    
    // 基本上如果你已經取出資料，是可以直接改資料的。只要寫在realm.write內即可
    func updateData2() {
        let realm = try! Realm()
        if let data = realm.objects(RLM_User.self).filter("name = 'Sam'").first {
            try! realm.write {
                data.address = "New Taipei City"
            }
        }
    }
    
    // 註：要注意的是，realm刪掉資料時並不會刪除檔案的磁區。但他會保留下來供日後其他新增的資料快速寫入。
    // 單一資料刪除
    func deleteData() {
        let realm = try! Realm()
        if let user = realm.objects(RLM_User.self).filter("name = 'Sam'").first {
            try! realm.write {
                realm.delete(user)
            }
        }
    }
    
    // 複合條件刪除
    func deleteResults(){
        let realm = try! Realm()
        let users = realm.objects(RLM_User.self).filter("name = 'Eagle'")
        try! realm.write {
            realm.delete(users)
        }
    }
    
    func testRLM() {
        // 生成訂單
        let realm = try! Realm()
        
        let order: Order = Order()
        order.name = "鞋子1000雙" // 訂單名稱
        order.amount = 60000 // 訂單金額
        
        // 新增資料
        try! realm.write {
            realm.add(order)
        }
        
        // 印出資料庫的位址
        print("fileURL: \(realm.configuration.fileURL!)")
    }
    
    // 多筆資料的話，為了效能考量，就比較不建議用這個方法，因為每提交一次就得必須消耗浪費一次效能，
    // 這時就可以使用將對資料庫操作的過程放在 beginWriteTransaction() 和 commitWriteTransaction() 之間，
    // 等資料處理完畢後，再一次性的提交
    func createManyOrder() {
        // 生成訂單
        let realm = try! Realm()
        
        let order: Order = Order()
        order.name = "鞋子1000雙" // 訂單名稱
        order.amount = 60000 // 訂單金額
        
        // 交易開始
        realm.beginWrite()
        
        // 生成100筆訂單資料
        for _ in 1 ... 100 {
            realm.add(order)
        }
        
        // 交易結束，並提交數據
        try! realm.commitWrite()
    }
    #endif
}
