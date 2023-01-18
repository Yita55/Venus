//
//  StepHistoryVC.swift
//  Venus
//
//  Created by Kenneth on 2017/Aug/13.
//  Copyright © 2017年 ADA. All rights reserved.
//

import UIKit
import RealmSwift
import Charts
import EZAlertController

class StepHistoryVC: UIViewController {
    struct stepDataStruct {
        var start_time: String
        var end_time: String
        var step_state: Int
        var step_count: Int
        var step_calorie: Int
    }
    
    var childScrollView: UIScrollView {
        return tableView
    }
    
    var goingUp: Bool?
    var childScrollingDownDueToParent = false
    var stepList: Results<step>!
    var tmpList: Results<step>!
    var btDataModel = BTDataModel.sharedInstance
    weak var axisFormatDelegate: IAxisValueFormatter?
    var stepDataOne = [stepDataStruct]()
    var stepDataTwo = [stepDataStruct]()
    var stepDataThree = [stepDataStruct]()
    var stepDataFour = [stepDataStruct]()
    var stepDataFive = [stepDataStruct]()
    var stepDataSix = [stepDataStruct]()
    var stepDataSeven = [stepDataStruct]()
    var dataMapDicts = [Int : [stepDataStruct]]()
    var currentDayIndex = 0
    var dayArray = [String]()
    var currentDataArray = [stepDataStruct]()
    var totalStep: Int = 0
    var totalCalorie: Int = 0
    var totalDistance: Double = 0
    var chartDict = [Int : stepDataStruct]()
    var plistManager = PlistManager()
    var strideLengthIntValue: Double = 0
    var heightIntValue: Int = 0
    var weightIntValue: Int = 0
    var genderValue: String = ""
    var ageIntValue: Int = 0
    var unitLengthValue = ""
    
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalStepLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var totalCalLabel: UILabel!
    
    @IBAction func refreshButtonTap(_ sender: AnyObject) {
        if btDataModel.btConnectedPeripheral == nil {
            EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"),
                                    message: PropertyUtils.readLocalizedProperty("no_device_bonded"),
                                    acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
            }
        } else {
            //====== connected device, start to sync ...
            btDataModel.isSyncAll = false
            btDataModel.queryHistoryOfStepFA()
        }
    }
    
    @IBAction func timeBackAction(_ sender: UIButton) {
        if currentDayIndex >= 6 {
            return
        } else {
            currentDayIndex += 1
        }
        useCurrentListThenUpdateUI(index: currentDayIndex)
    }
    
    @IBAction func timeForwardAction(_ sender: UIButton) {
        if currentDayIndex == 0 {
            return
        } else {
            currentDayIndex -= 1
        }
        useCurrentListThenUpdateUI(index: currentDayIndex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(StepHistoryVC.reloadDataThenUpdateUI), name: NSNotification.Name(rawValue: kSyncStepComplete), object: nil)
        
        parentScrollView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        axisFormatDelegate = self
        self.barChartView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.AlreadyOpenSetting) == true {
            if let plistManager = SharingManager.sharedInstance.plistManager {
                self.plistManager = plistManager
                
                print(plistManager.getCellContent(key: "step_goal"))
                print(plistManager.getCellContent(key: "height"))
                print(plistManager.getCellContent(key: "weight"))
                print("age=\(UserDefaults.standard.string(forKey: UserDefaultsKey.Age)!)")
                print(plistManager.getCellContent(key: "stride_len"))
                self.heightIntValue = Int(plistManager.getCellContent(key: "height"))!
                self.weightIntValue = Int(plistManager.getCellContent(key: "weight"))!
                let age = UserDefaults.standard.string(forKey: UserDefaultsKey.Age)!
                self.ageIntValue = Int(age)!
                self.genderValue = plistManager.getCellContent(key: "gender")
                self.strideLengthIntValue = Double(plistManager.getCellContent(key: "stride_len"))!
                
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
                print("age=\(UserDefaults.standard.string(forKey: UserDefaultsKey.Age)!)")
                print(self.plistManager.getCellContent(key: "stride_len"))
                self.heightIntValue = Int(self.plistManager.getCellContent(key: "height"))!
                self.weightIntValue = Int(self.plistManager.getCellContent(key: "weight"))!
                let age = UserDefaults.standard.string(forKey: UserDefaultsKey.Age)!
                self.ageIntValue = Int(age)!
                self.genderValue = self.plistManager.getCellContent(key: "gender")
                self.strideLengthIntValue = Double(self.plistManager.getCellContent(key: "stride_len"))!
                
                self.unitLengthValue = self.plistManager.getCellContent(key: "units_length")
                print(self.unitLengthValue)
            }
            else {
                let height = UserDefaults.standard.string(forKey: UserDefaultsKey.Height)!
                let weight = UserDefaults.standard.string(forKey: UserDefaultsKey.Weight)!
                let age = UserDefaults.standard.string(forKey: UserDefaultsKey.Age)!
                let strideLength = UserDefaults.standard.string(forKey: UserDefaultsKey.StrideLength)!
                self.heightIntValue = Int(height)!
                self.weightIntValue = Int(weight)!
                self.ageIntValue = Int(age)!
                self.genderValue = "male"
                self.strideLengthIntValue = Double(strideLength)!
                
                self.unitLengthValue = "cm/km"
                print(self.unitLengthValue)
            }
        }
        
        if btDataModel.btConnectedPeripheral == nil {
            EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"),
                                    message: PropertyUtils.readLocalizedProperty("no_device_bonded"),
                                    acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
#if false
                    let stepList = self.getStepListFromDatabase()
                    if stepList.count == 0 {
                        // 1 => WALK 2 => RUN
                        self.btDataModel.insertToDB_0xFA(startTime: "2018/01/23-10:10:10", endTime: "2018/01/23-11:11:11", stepCount: 1000, stepState: 1, stepCalorie: 2)
                        self.btDataModel.insertToDB_0xFA(startTime: "2018/01/23-11:12:12", endTime: "2018/01/23-13:11:11", stepCount: 1000, stepState: 1, stepCalorie: 2)
                        self.btDataModel.insertToDB_0xFA(startTime: "2018/01/23-13:12:10", endTime: "2018/01/23-14:12:11", stepCount: 1000, stepState: 1, stepCalorie: 2)
                        self.btDataModel.insertToDB_0xFA(startTime: "2018/01/23-14:13:10", endTime: "2018/01/23-14:16:11", stepCount: 1000, stepState: 1, stepCalorie: 2)
                        self.btDataModel.insertToDB_0xFA(startTime: "2018/01/23-15:10:10", endTime: "2018/01/23-15:11:11", stepCount: 1000, stepState: 1, stepCalorie: 2)
                        self.btDataModel.insertToDB_0xFA(startTime: "2018/01/23-15:20:10", endTime: "2018/01/23-15:23:11", stepCount: 1000, stepState: 1, stepCalorie: 2)
                        self.btDataModel.insertToDB_0xFA(startTime: "2018/01/23-15:30:10", endTime: "2018/01/23-15:36:11", stepCount: 1000, stepState: 1, stepCalorie: 2)
                        self.btDataModel.insertToDB_0xFA(startTime: "2018/1/22-11:12:12", endTime: "2018/1/22-11:13:13", stepCount: 3000, stepState: 2, stepCalorie: 2)
                        self.btDataModel.insertToDB_0xFA(startTime: "2018/1/22-14:15:14", endTime: "2018/1/22-14:24:14", stepCount: 1000, stepState: 1, stepCalorie: 2)
                        self.btDataModel.insertToDB_0xFA(startTime: "2018/1/22-15:15:15", endTime: "2018/1/22-15:15:15", stepCount: 2220, stepState: 2, stepCalorie: 2)
                        
                        self.btDataModel.insertToDB_0xFA(startTime: "2018/1/21-19:51:10", endTime: "2018/1/21-19:52:10", stepCount: 4100, stepState: 1, stepCalorie: 2)
                        self.btDataModel.insertToDB_0xFA(startTime: "2018/1/21-20:11:10", endTime: "2018/1/21-20:51:12", stepCount: 2900, stepState: 2, stepCalorie: 2)
                        
                        self.btDataModel.insertToDB_0xFA(startTime: "2017/9/30-20:51:10", endTime: "2017/9/30-20:52:10", stepCount: 4100, stepState: 1, stepCalorie: 2)
                        self.btDataModel.insertToDB_0xFA(startTime: "2017/9/30-21:11:10", endTime: "2017/9/30-22:51:12", stepCount: 2900, stepState: 2, stepCalorie: 2)
                        
                        self.btDataModel.insertToDB_0xFA(startTime: "2017/9/29-20:51:10", endTime: "2017/9/29-20:53:10", stepCount: 5100, stepState: 1, stepCalorie: 2)
                        self.btDataModel.insertToDB_0xFA(startTime: "2017/9/29-21:11:10", endTime: "2017/9/29-21:51:12", stepCount: 1900, stepState: 2, stepCalorie: 2)
                        
                        self.btDataModel.insertToDB_0xFA(startTime: "2017/9/28-11:51:10", endTime: "2017/9/28-12:51:10", stepCount: 4100, stepState: 1, stepCalorie: 2)
                        self.btDataModel.insertToDB_0xFA(startTime: "2017/9/28-20:11:10", endTime: "2017/9/28-20:51:12", stepCount: 1900, stepState: 2, stepCalorie: 2)
                    }
#endif
                self.reloadDataThenUpdateUI()
            }
        } else {
            //====== connected device, start to sync ...
            btDataModel.isSyncAll = false
            btDataModel.queryHistoryOfStepFA()
        }
        
        self.totalStepLabel.text = "\(self.totalStep)"
        
        let distanceStr: String = String(format: "%.1f", self.totalDistance)
        
        if self.unitLengthValue == "cm/km" {
            self.totalDistanceLabel.text = "\(distanceStr) " + PropertyUtils.readLocalizedProperty("distance_unit_km")
        } else {
            self.totalDistanceLabel.text = "\(distanceStr) " + PropertyUtils.readLocalizedProperty("distance_unit_mile")
        }
        
        self.totalCalLabel.text = "\(self.totalCalorie) " + PropertyUtils.readLocalizedProperty("calorie_unit")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.navigationController?.topViewController != self {
            print("in StepHistory View, back button tapped!")
            SharingManager.sharedInstance.isBackFromStepHistory = true
        }
    }
    
    func checkInTimeRange(sDate: Date, eDate: Date, checkDate: Date) -> Bool {
        if checkDate >= sDate &&
            checkDate <= eDate {
            print("The time \(checkDate) is between \(sDate) and \(eDate)")
            return true
        }
        return false
    }
    
    func updateChartWithData(currentList: [stepDataStruct], dayIndex: Int) {
        self.currentDataArray = currentList
        self.chartDict.removeAll()
        
        var dataEntries: [BarChartDataEntry] = []
        
        self.lastTimeLabel.text = self.dayArray[dayIndex]
        
        if currentList.count > 0 {
            self.noteLabel.text = ""
        } else {
            self.noteLabel.text = PropertyUtils.readLocalizedProperty("no data")
            self.totalStep = 0
            
            let chartDataSet = BarChartDataSet(values: dataEntries, label: "Step Count")
            let chartData = BarChartData(dataSet: chartDataSet)
            
            chartDataSet.colors = [UIColor.blue]
            chartDataSet.valueTextColor = UIColor.clear
            barChartView.xAxis.drawGridLinesEnabled = false
            barChartView.xAxis.drawAxisLineEnabled = false
            barChartView.rightAxis.enabled = false
            barChartView.leftAxis.enabled = false
            barChartView.legend.enabled = false
            barChartView.chartDescription?.enabled = false
            barChartView.chartDescription?.text = ""
            barChartView.drawValueAboveBarEnabled = false
            barChartView.noDataText = "You need to provide data for the chart."
            barChartView.data = chartData
            let xaxis = barChartView.xAxis
            xaxis.valueFormatter = axisFormatDelegate
            
            for _ in 0..<self.currentDataArray.count {
                self.removeUnknownItem()
            }
            self.tableView.reloadData()
            self.tableView.tableFooterView = UIView(frame: CGRect.zero)
            
            return
        }
        
        //var colorArray = [UIColor]()
        // 24 x 60 = 1440 / 10 = 144
        // 00:00 ~ 23:59
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let fromDate = "\(self.dayArray[dayIndex])-00:00:00"        
        print("fromDate=\(fromDate)")
        //let fffDate = dateFormatter.date(from: fromDate)!
        //let mDate = fffDate.addingTimeInterval(300)
        //let eDate = fDate!.addingTimeInterval(600)
        //let dateArray = [Date(), Date().yesterday, Date().yester2day, mDate, Date().yesterday]
        var fDate = dateFormatter.date(from: fromDate)!
        var eDate: Date?
        
        for i in 0..<144 {
            eDate = fDate.addingTimeInterval(600)
            //print("\(fDate) \(eDate!)")
            for j in 0..<currentList.count {
                //print("\(currentList[j].start_time)")
                let startTime = dateFormatter.date(from: currentList[j].start_time)
                
                if checkInTimeRange(sDate: fDate, eDate: eDate!, checkDate: startTime!) == true {
                    let walkDataEntry = BarChartDataEntry(x: Double(i),
                                                          y: Double(currentList[j].step_count))
                    dataEntries.append(walkDataEntry)
                    self.chartDict[i] = currentList[j]
                    self.totalStep += currentList[j].step_count
                } else {
                    let zeroDataEntry = BarChartDataEntry(x: Double(i),
                                                          y: 0.0)
                    dataEntries.append(zeroDataEntry)
                }
            }
            fDate = eDate!
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Step Count")
        let chartData = BarChartData(dataSet: chartDataSet)
        
        //chartDataSet.colors = [UIColor.yellow, UIColor.blue, UIColor.red, UIColor.yellow, UIColor.green, UIColor.red]
        //chartDataSet.colors = colorArray
        chartDataSet.colors = [UIColor.blue]
        chartDataSet.valueTextColor = UIColor.clear
        //barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = false
        
        barChartView.legend.enabled = false
        barChartView.chartDescription?.enabled = false
        barChartView.chartDescription?.text = ""
        barChartView.drawValueAboveBarEnabled = false
        
        barChartView.noDataText = "You need to provide data for the chart."
        
        barChartView.data = chartData
        
        let xaxis = barChartView.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        
        for _ in 0..<self.currentDataArray.count {
            self.removeUnknownItem()
        }
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func getStepListFromDatabase() -> Results<step> {
        do {
            let realm = try Realm()
            self.tmpList = realm.objects(step.self)
            SharingManager.sharedInstance.currentStepListCount = self.tmpList.count
            self.stepList = self.tmpList.sorted(byKeyPath: "start_time", ascending: false)
            return self.stepList
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func processCreateDataMap(sourceData: Results<step>) -> [stepDataStruct] {
        
        self.dayArray.removeAll()
        self.stepDataOne.removeAll()
        self.stepDataTwo.removeAll()
        self.stepDataThree.removeAll()
        self.stepDataFour.removeAll()
        self.stepDataFive.removeAll()
        self.stepDataSix.removeAll()
        self.stepDataSeven.removeAll()
        self.dataMapDicts.removeAll()
        
        //let today = Date()
        //let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)
        var date = Date()
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        
        let year = components.year!
        let month = components.month!
        let day = components.day!
        
        let today = String(format: "%04i/%02i/%02i", year, month, day)
        
        date = Date().yesterday
        let yesterday = String(format: "%04i/%02i/%02i", date.year, date.month, date.day)
        print(yesterday)
        
        date = Date().yester2day
        let yester2day = String(format: "%04i/%02i/%02i", date.year, date.month, date.day)
        print(yester2day)
        
        date = Date().yester3day
        let yester3day = String(format: "%04i/%02i/%02i", date.year, date.month, date.day)
        print(yester3day)
        
        date = Date().yester4day
        let yester4day = String(format: "%04i/%02i/%02i", date.year, date.month, date.day)
        print(yester4day)
        
        date = Date().yester5day
        let yester5day = String(format: "%04i/%02i/%02i", date.year, date.month, date.day)
        print(yester5day)
        
        date = Date().yester6day
        let yester6day = String(format: "%04i/%02i/%02i", date.year, date.month, date.day)
        print(yester6day)
        
        self.dayArray.append(today)
        self.dayArray.append(yesterday)
        self.dayArray.append(yester2day)
        self.dayArray.append(yester3day)
        self.dayArray.append(yester4day)
        self.dayArray.append(yester5day)
        self.dayArray.append(yester6day)
        
        for i in 0 ..< sourceData.count {
            let item = stepDataStruct(start_time: sourceData[i].start_time,
                                      end_time: sourceData[i].end_time,
                                      step_state: sourceData[i].step_state,
                                      step_count: sourceData[i].step_count,
                                      step_calorie: sourceData[i].step_calorie)
            
            if sourceData[i].start_time.range(of: today) != nil {
                print("Today")
                
                self.stepDataOne.append(item)
                
            } else if sourceData[i].start_time.range(of: yesterday) != nil {
                print("yesterday")
                
                self.stepDataTwo.append(item)
                
            } else if sourceData[i].start_time.range(of: yester2day) != nil {
                print("yester 2 day")
                
                self.stepDataThree.append(item)
                
            } else if sourceData[i].start_time.range(of: yester3day) != nil {
                print("yester 3 day")
                
                self.stepDataFour.append(item)
                
            } else if sourceData[i].start_time.range(of: yester4day) != nil {
                print("yester 4 day")
                
                self.stepDataFive.append(item)
                
            } else if sourceData[i].start_time.range(of: yester5day) != nil {
                print("yester 5 day")
                
                self.stepDataSix.append(item)
                
            } else if sourceData[i].start_time.range(of: yester6day) != nil {
                print("yester 6 day")
                
                self.stepDataSeven.append(item)
                
            }
        }
        
        self.dataMapDicts[0] = self.stepDataOne
        self.dataMapDicts[1] = self.stepDataTwo
        self.dataMapDicts[2] = self.stepDataThree
        self.dataMapDicts[3] = self.stepDataFour
        self.dataMapDicts[4] = self.stepDataFive
        self.dataMapDicts[5] = self.stepDataSix
        self.dataMapDicts[6] = self.stepDataSeven
        
        return self.stepDataOne
    }
    
    func updateUI() {
        self.startTimeLabel.text = "00:00"
        self.endTimeLabel.text = "23:59"
        
        //let endTime = self.currentDataArray[self.currentDataArray.count - 1].start_time
        //let endTimeSepArray = endTime.components(separatedBy: "-")
        //self.endTimeLabel.text = endTimeSepArray[1]
        //let separatedArray = self.currentDataArray[0].start_time.components(separatedBy: "-")
        //self.startTimeLabel.text = separatedArray[1]

        // need to check
#if false
        if self.currentDataArray.count > 0 {
            self.totalStepLabel.text = "\(self.totalStep)"
            self.totalDistanceLabel.text = computeDistance(stepNum: self.totalStep)
            self.totalCalLabel.text = "\(computeTotalCal()) " + PropertyUtils.readLocalizedProperty("calorie_unit")
        }
#endif
    }
    
    func useCurrentListThenUpdateUI(index: Int) {
        let currentList = self.dataMapDicts[index]!
        // update chart
        updateChartWithData(currentList: currentList, dayIndex: index)
        // update UI
        updateUI()
    }
    
    func reloadDataThenUpdateUI() {
        let stepList = getStepListFromDatabase()
        let todayList = self.processCreateDataMap(sourceData: stepList)
        // update chart
        updateChartWithData(currentList: todayList, dayIndex: 0)
        // update UI
        updateUI()
    }
    
    func computeDuration(sTime: String, eTime: String) -> String {
        var durationHourStr = ""
        var durationMinuteStr = ""
        //var durationSecondStr = ""
        //let date1Str = "2017/9/19-10:10:10"
        //let date2Str = "2017/9/19-12:10:1"
        let dateFormatterX = DateFormatter()
        dateFormatterX.dateFormat = "yyyy/MM/dd-HH:mm:ss"
        let sDate = dateFormatterX.date(from: sTime)
        let eDate = dateFormatterX.date(from: eTime)
        
        //let calendar = NSCalendar.current
        //let unitFlags:NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month , NSCalendar.Unit.day , NSCalendar.Unit.hour , NSCalendar.Unit.minute , NSCalendar.Unit.second]
        let components = Calendar.current.dateComponents([.year, .month, .hour, .minute, .second],
                                                         from: sDate!,
                                                         to: eDate!)
        print("computeDuration :: sTime=\(sTime) ~ eTime=\(eTime)")
        print(components.year ?? 0)
        print(components.month ?? 0)
        print(components.day ?? 0)
        print(components.hour ?? 0)
        print(components.minute ?? 0)
        print(components.second ?? 0)
        
        if components.hour != 0 {
            durationHourStr = "\(abs(components.hour!))" + PropertyUtils.readLocalizedProperty("timepicker_hour") + " "
        }
        if components.minute != 0 {
            durationMinuteStr = "\(abs(components.minute!))" + PropertyUtils.readLocalizedProperty("time_min")
        } else {
            durationMinuteStr = "1" + PropertyUtils.readLocalizedProperty("time_min")
        }
        //if components.second != 0 {
        //    durationSecondStr = "\(components.second!)sec"
        //}
        
        return durationHourStr + durationMinuteStr
    }
    
    func computeDistance(stepNum: Int) -> String {
        ///let distance_M = self.strideLengthIntValue * stepNum / 100
        let distance_KM = self.strideLengthIntValue * Double(stepNum) / 100 / 1000
        let distance_MILE: Double = self.strideLengthIntValue * Double(stepNum) / 100 / 1000 * 0.621
        
        if self.unitLengthValue == "cm/km" {
            let distanceStr: String = String(format: "%.1f", distance_KM)
            return distanceStr + PropertyUtils.readLocalizedProperty("distance_unit_km")
        } else {
            let distanceStr: String = String(format: "%.1f", distance_MILE)
            return distanceStr + PropertyUtils.readLocalizedProperty("distance_unit_mile")
        }
        
        //if distance_M > 1000 {
        //    return "\(distance_KM)" + PropertyUtils.readLocalizedProperty("distance_unit_km")
        //} else {
        //    return "\(distance_M)" + PropertyUtils.readLocalizedProperty("distance_unit_m")
        //}
    }
    
    func computeTotalCal() -> Int {
        var totalCal: Int = 0
        for item in self.currentDataArray {
            totalCal += item.step_calorie
        }
        return totalCal
    }

    func computeCal(stepNum: Int, stepState: Int) -> String {
        let calorie = CalcUtils.calcStepsCalorie(steps: stepNum,
                                                 height: self.heightIntValue,
                                                 weight: self.weightIntValue,
                                                 gender: self.genderValue,
                                                 age: self.ageIntValue,
                                                 stepState: stepState)
        return "\(calorie) Cal"
    }
    
    func checkTime(sTime: String, eTime: String) -> Bool {
        let dateFormatterX = DateFormatter()
        dateFormatterX.dateFormat = "yyyy/MM/dd-HH:mm:ss"
        let sDate = dateFormatterX.date(from: sTime)
        let eDate = dateFormatterX.date(from: eTime)
        
        
        let components = Calendar.current.dateComponents([.year, .month, .hour, .minute, .second],
                                                         from: sDate!,
                                                         to: eDate!)
        print("checkTime :: sTime=\(sTime) ~ eTime=\(eTime)")
        print(components.year ?? 0)
        print(components.month ?? 0)
        print(components.day ?? 0)
        print(components.hour ?? 0)
        print(components.minute ?? 0)
        print(components.second ?? 0)
        
        if components.hour! < 0 {
            return false
        }
        if components.minute! < 0 {
            return false
        }
        
        return true
    }
    
    func removeUnknownItem() {
        // already copy
        let currData = self.currentDataArray
        
        //var unwantedValues: Set<Int> = [2, 4, 5]
        //unwantedValues.insert(0)
        //unwantedValues.insert(1)
        //array = array.filter{!unwantedValues.contains($0)}
        
        for i in 0..<currData.count {
            if checkTime(sTime: currData[i].start_time, eTime: currData[i].end_time) == false {
                // remove item
                self.currentDataArray.remove(at: i)
                break
            } else if currData[i].step_count == 0 {
                // remove item
                self.currentDataArray.remove(at: i)
                break
            } else {
                // do nothing
            }
        }
    }
}

extension StepHistoryVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath) as! StepCell
        
        //cell.timeLabel.text = self.heartRateList[indexPath.row].time
        //cell.bpmLabel.text = "\(self.heartRateList[indexPath.row].heart_rate_value)"
        
        let stepData = self.currentDataArray[indexPath.row]
        
        if stepData.step_state == 1 {
            // WALK
            cell.stepImageView.image = UIImage(named: "ic_list_item_walk")
            cell.stepImageView.layer.cornerRadius = cell.stepImageView.frame.width * 0.5
            cell.stepStateLabel.text = PropertyUtils.readLocalizedProperty("step_walking")
        
        } else {
            // RUN
            cell.stepImageView.image = UIImage(named: "ic_list_item_run")
            cell.stepImageView.layer.cornerRadius = cell.stepImageView.frame.width * 0.5
            cell.stepStateLabel.text = PropertyUtils.readLocalizedProperty("step_running")
        }
        let separatedStartTime = stepData.start_time.components(separatedBy: "-")[1]
        let tmpArrayOfStartTime = separatedStartTime.components(separatedBy: ":")
        let separatedEndTime = stepData.end_time.components(separatedBy: "-")[1]
        let tmpArrayOfEndTime = separatedEndTime.components(separatedBy: ":")
        cell.timeLabel.text = "\(tmpArrayOfStartTime[0]):\(tmpArrayOfStartTime[1])~\(tmpArrayOfEndTime[0]):\(tmpArrayOfEndTime[1])"
        cell.durationLabel.text = "\(computeDuration(sTime: stepData.start_time, eTime: stepData.end_time))"
        cell.stepCountLabel.text = "\(stepData.step_count) " + PropertyUtils.readLocalizedProperty("step_unit")
        cell.distanceLabel.text = computeDistance(stepNum: stepData.step_count)
        cell.calorieLabel.text = "\(stepData.step_calorie) " + PropertyUtils.readLocalizedProperty("calorie_unit")

        return cell
    }
    
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Remove separator inset
        cell.separatorInset = UIEdgeInsets.zero
        // Prevent the cell from inheriting the Table View's margin settings
        cell.preservesSuperviewLayoutMargins = false
        // Explictly set your cell's layout margins
        cell.layoutMargins = UIEdgeInsets.zero   
    }
}

extension StepHistoryVC: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // determining whether scrollview is scrolling up or down
        goingUp = scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
        
        // maximum contentOffset y that parent scrollView can have
        let parentViewMaxContentYOffset = parentScrollView.contentSize.height - parentScrollView.frame.height
        
        // if scrollView is going upwards
        if goingUp! {
            // if scrollView is a child scrollView
            
            if scrollView == childScrollView {
                // if parent scroll view is't scrolled maximum (i.e. menu isn't sticked on top yet)
                if parentScrollView.contentOffset.y < parentViewMaxContentYOffset && !childScrollingDownDueToParent {
                    
                    // change parent scrollView contentOffset y which is equal to minimum between maximum y offset that parent scrollView can have and sum of parentScrollView's content's y offset and child's y content offset. Because, we don't want parent scrollView go above sticked menu.
                    // Scroll parent scrollview upwards as much as child scrollView is scrolled
                    // Sometimes parent scrollView goes in the middle of screen and stucks there so max is used.
                    parentScrollView.contentOffset.y = max(min(parentScrollView.contentOffset.y + childScrollView.contentOffset.y, parentViewMaxContentYOffset), 0)
                    
                    // change child scrollView's content's y offset to 0 because we are scrolling parent scrollView instead with same content offset change.
                    childScrollView.contentOffset.y = 0
                }
            }
        }
            // Scrollview is going downwards
        else {
            
            if scrollView == childScrollView {
                // when child view scrolls down. if childScrollView is scrolled to y offset 0 (child scrollView is completely scrolled down) then scroll parent scrollview instead
                // if childScrollView's content's y offset is less than 0 and parent's content's y offset is greater than 0
                if childScrollView.contentOffset.y < 0 && parentScrollView.contentOffset.y > 0 {
                    
                    // set parent scrollView's content's y offset to be the maximum between 0 and difference of parentScrollView's content's y offset and absolute value of childScrollView's content's y offset
                    // we don't want parent to scroll more that 0 i.e. more downwards so we use max of 0.
                    parentScrollView.contentOffset.y = max(parentScrollView.contentOffset.y - abs(childScrollView.contentOffset.y), 0)
                }
            }
            
            // if downward scrolling view is parent scrollView
            if scrollView == parentScrollView {
                // if child scrollView's content's y offset is greater than 0. i.e. child is scrolled up and content is hiding up
                // and parent scrollView's content's y offset is less than parentView's maximum y offset
                // i.e. if child view's content is hiding up and parent scrollView is scrolled down than we need to scroll content of childScrollView first
                if childScrollView.contentOffset.y > 0 && parentScrollView.contentOffset.y < parentViewMaxContentYOffset {
                    // set if scrolling is due to parent scrolled
                    childScrollingDownDueToParent = true
                    // assign the scrolled offset of parent to child not exceding the offset 0 for child scroll view
                    childScrollView.contentOffset.y = max(childScrollView.contentOffset.y - (parentViewMaxContentYOffset - parentScrollView.contentOffset.y), 0)
                    // stick parent view to top coz it's scrolled offset is assigned to child
                    parentScrollView.contentOffset.y = parentViewMaxContentYOffset
                    childScrollingDownDueToParent = false
                }
            }
        }
    }
}

// MARK: axisFormatDelegate
extension StepHistoryVC: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return ""
    }
}

extension StepHistoryVC: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("\(Int(entry.x)), \(entry.y)")
        self.noteLabel.text = ""
        if entry.y > 0.0 {
            if let item = self.chartDict[Int(entry.x)] {
                let startTime = item.start_time
                let separatedStartTime = startTime.components(separatedBy: "-")
                let stepCount = item.step_count
                
                self.noteLabel.text = "\(separatedStartTime[1]) \(stepCount)" + PropertyUtils.readLocalizedProperty("step_unit")
            }
        }
    }
}
