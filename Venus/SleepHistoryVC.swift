//
//  SleepHistoryVC.swift
//  Venus
//
//  Created by Kenneth on 2017/Aug/13.
//  Copyright © 2017年 ADA. All rights reserved.
//

import UIKit
import RealmSwift
import Charts
import EZAlertController

struct sleepDataStructTestGit140 {
    var start_time: String
    var duration: Int
    var sleep_state: Int
}

struct sleepDataStruct {
    var start_time: String
    var duration: Int
    var sleep_state: Int
}

class SleepHistoryVC: UIViewController {
    
    // AWAKE => 0 , 4
    // DEEP => 1
    // LIGHT => 2
    // idle => 8 濾掉
    enum SleepState: Int {
        case Awake = 0, Deep = 1, Light = 2, Rollover = 4
        
        func stateString() -> String {
            switch rawValue {
            case 0, 4:
                return PropertyUtils.readLocalizedProperty("sleep_awake")
            case 1:
                return PropertyUtils.readLocalizedProperty("sleep_deep")
            case 2:
                return PropertyUtils.readLocalizedProperty("sleep_light")
            default:
                return PropertyUtils.readLocalizedProperty("")
            }
        }
    }
    
    var tmpList: Results<sleep>!
    var sleepList: Results<sleep>!
    weak var axisFormatDelegate: IAxisValueFormatter?
    var btDataModel = BTDataModel.sharedInstance
    //var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    //let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
    var sleepInfoOne = [sleepDataStruct]()
    var sleepInfoTwo = [sleepDataStruct]()
    var sleepInfoThree = [sleepDataStruct]()
    var sleepInfoFour = [sleepDataStruct]()
    var sleepInfoFive = [sleepDataStruct]()
    var sleepInfoSix = [sleepDataStruct]()
    var sleepInfoSeven = [sleepDataStruct]()
    var dataMapDicts = [Int : [sleepDataStruct]]()
    var currentDayIndex = 0
    var sleepInfoArray = [String]()
    var currentDataArray = [sleepDataStruct]()
    var secondOfDeep: Int = 0
    var secondOfLight: Int = 0
    var secondOfInBed: Int = 0
    var secondOfFellaslssp: Int = 0
    var secondOfWokeUp: Int = 0
    var secondOfAwake: Int = 0
    let hourStr: String = PropertyUtils.readLocalizedProperty("timepicker_hour")
    let minStr: String = PropertyUtils.readLocalizedProperty("timepicker_minute")
    var plistManager = PlistManager()
    var sleepTime: String = ""
    var sleepStartTime: String = ""
    var sleepEndTime: String = ""
    
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var inBedForLabel: UILabel!
    
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var deepSleepLabel: UILabel!
    
    @IBOutlet weak var title3Label: UILabel!
    @IBOutlet weak var lightSleepLabel: UILabel!
    
    @IBOutlet weak var title4Label: UILabel!
    @IBOutlet weak var fellAsleepLabel: UILabel!
    
    @IBOutlet weak var title5Label: UILabel!
    @IBOutlet weak var wokeUpLabel: UILabel!
    
    @IBOutlet weak var title6Label: UILabel!
    @IBOutlet weak var awakeTimeLabel: UILabel!
    
    @IBAction func refreshButtonTap(_ sender: AnyObject) {
        // Click on the "Update" button
        if btDataModel.btConnectedPeripheral == nil {
            EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"), message: PropertyUtils.readLocalizedProperty("no_device_bonded"), acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
                print("cliked OK")
            }
        } else {
            //====== connected device, start to sync ...
            btDataModel.isSyncAll = false
            btDataModel.queryHistoryOfSleepFC()
        }
    }
    
    @IBAction func timeBackAction(_ sender: UIButton) {
        print(currentDayIndex)
        if currentDayIndex >= 6 {
            return
        } else {
            currentDayIndex += 1
        }
        print(currentDayIndex)
        useCurrentListThenUpdateUI(index: currentDayIndex)
    }
    
    @IBAction func timeForwardAction(_ sender: UIButton) {
        print(currentDayIndex)
        if currentDayIndex == 0 {
            return
        } else {
            currentDayIndex -= 1
        }
        print(currentDayIndex)
        useCurrentListThenUpdateUI(index: currentDayIndex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(SleepHistoryVC.reloadDataThenUpdateUI), name: NSNotification.Name(rawValue: kSyncSleepComplete), object: nil)
        
        axisFormatDelegate = self
        self.barChartView.delegate = self
        
        if btDataModel.btConnectedPeripheral == nil {
            EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"), message: PropertyUtils.readLocalizedProperty("no_device_bonded"), acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
                print("cliked OK")
                
#if false
                    let sleepList = self.getSleepListFromDatabase()
                    
                    
                    if sleepList.count == 0 {
                        // AWAKE => 0 , 4
                        // DEEP => 1
                        // LIGHT => 2
                        // idle => 8 濾掉
                        //  2017.10.17-22:00:00
                        self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-08:00:00", duration: 120, sleepState: 0)
                        self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-04:36:00", duration: 1440, sleepState: 0)
                        self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-04:02:00", duration: 1260, sleepState: 2)
                        self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-01:50:00", duration: 368, sleepState: 2)
                        self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-02:07:00", duration: 3022, sleepState: 1)
                        self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-02:18:00", duration: 3466, sleepState: 2)
                        self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-03:44:00", duration: 392, sleepState: 1)
                        self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-04:02:00", duration: 3423, sleepState: 2)
                        
                    }
#endif
            
                
#if false
                let sleepList = self.getSleepListFromDatabase()
    

                if sleepList.count == 0 {
                    // AWAKE => 0 , 4
                    // DEEP => 1
                    // LIGHT => 2
                    // idle => 8 濾掉
                    //  2017.10.17-22:00:00
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/11-22:00:00", duration: 120, sleepState: 1)
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-08:00:00", duration: 1440, sleepState: 0)
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/11-22:07:00", duration: 1260, sleepState: 2)
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/11-22:31:09", duration: 368, sleepState: 0)
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/11-22:53:00", duration: 3022, sleepState: 1)
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/11-23:07:00", duration: 3466, sleepState: 0)
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/11-23:28:10", duration: 392, sleepState: 2)
                    
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/11-23:40:00", duration: 3423, sleepState: 1)
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/11-23:42:00", duration: 3281, sleepState: 2)
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/11-23:48:00", duration: 200, sleepState: 1)
                    

                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-00:59:00", duration: 245, sleepState: 2)
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-01:38:00", duration: 245, sleepState: 1)
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-02:05:00", duration: 245, sleepState: 2)
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-03:04:00", duration: 245, sleepState: 1)
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-03:17:00", duration: 245, sleepState: 2)
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-03:28:00", duration: 245, sleepState: 1)
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-03:39:00", duration: 245, sleepState: 2)
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-04:05:00", duration: 245, sleepState: 1)
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-04:29:00", duration: 245, sleepState: 2)
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-04:40:00", duration: 245, sleepState: 1)
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-04:51:00", duration: 245, sleepState: 2)
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-05:19:00", duration: 245, sleepState: 1)
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-05:53:00", duration: 245, sleepState: 2)
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-06:06:00", duration: 245, sleepState: 1)
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-06:42:00", duration: 245, sleepState: 2)
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-07:33:00", duration: 245, sleepState: 0)
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-07:48:00", duration: 245, sleepState: 2)
                    
                    self.btDataModel.insertToDB_0xFC(startTime: "2017/12/12-08:03:00", duration: 245, sleepState: 0)

                    
                }
#endif
                
                
                
                self.reloadDataThenUpdateUI()
                
            }
        } else {
            //====== connected device, start to sync ...
            btDataModel.isSyncAll = false
            btDataModel.queryHistoryOfSleepFC()
        }
        
        self.title1Label.text = PropertyUtils.readLocalizedProperty("sleep_in_bed")
        self.title2Label.text = PropertyUtils.readLocalizedProperty("sleep_deep_day")
        self.title3Label.text = PropertyUtils.readLocalizedProperty("sleep_light_day")
        self.title4Label.text = PropertyUtils.readLocalizedProperty("sleep_at")
        self.title5Label.text = PropertyUtils.readLocalizedProperty("sleep_wake_at")
        self.title6Label.text = PropertyUtils.readLocalizedProperty("sleep_awake_time")
        
        /*
        // 查詢資料
        let realm = try! Realm()
        self.sleepList = realm.objects(sleep.self)
        */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.AlreadyOpenSetting) == true {
            if let plistManager = SharingManager.sharedInstance.plistManager {
                self.plistManager = plistManager
                self.sleepTime = plistManager.getCellContent(key: "sleep_time")
                print(plistManager.getCellContent(key: "sleep_time"))
                self.sleepStartTime = self.sleepTime.components(separatedBy: "~")[0]
                self.sleepEndTime = self.sleepTime.components(separatedBy: "~")[1]
            }
        }
        else {
            if self.plistManager.openPlist() == true {
                print("plist openPlist == true!")
                print(self.plistManager.getCellContent(key: "sleep_time"))
                self.sleepTime = self.plistManager.getCellContent(key: "sleep_time")
                self.sleepStartTime = self.sleepTime.components(separatedBy: "~")[0]
                self.sleepEndTime = self.sleepTime.components(separatedBy: "~")[1]
            }
            else {
                print("Unknown Error!")
                self.sleepTime = "21:00~10:00"
                self.sleepStartTime = "21:00"
                self.sleepEndTime = "10:00"
            }
        }
    }
    
    
    /*
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            //let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            let dataEntry = BarChartDataEntry(
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Units Sold")
        let chartData = BarChartData(xVals: months, dataSet: chartDataSet)
        barChartView.data = chartData
        
        barChartView.description = ""
        
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        //        chartDataSet.colors = ChartColorTemplates.colorful()
        
        barChartView.xAxis.labelPosition = .Bottom
        
        //        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        
        //        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInBounce)
        
        let ll = ChartLimitLine(limit: 10.0, label: "Target")
        barChartView.rightAxis.addLimitLine(ll)
        
    }
    */
    
    func updateChartWithData(currentList: [sleepDataStruct], dayIndex: Int) {
        self.currentDataArray = currentList
        
        secondOfDeep = 0
        secondOfLight = 0
        secondOfInBed = 0
        secondOfFellaslssp = 0
        secondOfWokeUp = 0
        secondOfAwake = 0
        
        var dataEntries: [BarChartDataEntry] = []
        
        self.lastTimeLabel.text = self.sleepInfoArray[dayIndex]
        
        if self.currentDataArray.count > 0 {
            //let separatedStrs = currentList[0].start_time.components(separatedBy: "-")
            //let currentDate = separatedStrs[0]
            self.noteLabel.text = ""
            
            
        } else {
            /*
            let date = Date()
            let calendar = NSCalendar.current
            
            let components = calendar.dateComponents([.day, .month, .year], from: date)
            
            let year = components.year!
            let month = components.month!
            let day = components.day!
            
            let today = "\(year)/\(month)/\(day)"
            */
            self.noteLabel.text = PropertyUtils.readLocalizedProperty("no data")
            self.endTimeLabel.text = "00:00"
        }
        
        var colorArray = [UIColor]()
        
        
        //var numOfLine = 0
        print("self.currentDataArray.count=\(self.currentDataArray.count)")
        //if currentList.count > 0 {
        //    numOfLine = currentList.count - 1
        //}
        //print("numOfLine=\(numOfLine)")
        //print("========")
        // 0 ~ 5
        //let lastItem = numOfLine - 1
        if self.currentDataArray.count > 0 {
            for i in stride(from: self.currentDataArray.count-1, through: 0, by: -1) {
                print("start_time=\(self.currentDataArray[i].start_time) state=\(self.currentDataArray[i].sleep_state)")
                if self.currentDataArray[i].sleep_state == 0 || self.currentDataArray[i].sleep_state == 4 {
                    print("remove item \(self.currentDataArray[i].start_time) \(self.currentDataArray[i].sleep_state) from self.currentDataArray!")
                    //var animals = ["cats", "dogs", "chimps", "moose"]
                    //animals.remove(at: 2)  //["cats", "dogs", "moose"]
                    self.currentDataArray.remove(at: i)
                } else {
                    break
                }
            }
        }
        
        let lastItem = self.currentDataArray.count - 1
        for i in 0 ..< self.currentDataArray.count {
        //for i in 0 ..< numOfLine {
            //print(i)
            //print(currentList[i].duration)
            // 10:14 yr_deng 淺灰就是淺眠
            // 10:14 yr_deng 深灰就是深眠
            // 黃色就是清醒
            // AWAKE => 0 , 4
            // DEEP => 1
            // LIGHT => 2
            // idle => 8 濾掉
            
            print("start_time=\(self.currentDataArray[i].start_time) state=\(self.currentDataArray[i].sleep_state)")
            //let timeIntervalForDate: TimeInterval = sleepList[i].start_time.timeIntervalSince1970
            //let dataEntry = BarChartDataEntry(x: Double(timeIntervalForDate),
            if self.currentDataArray[i].sleep_state == 2 {
                let lightDataEntry = BarChartDataEntry(x: Double(i),
                                                       y: Double(self.currentDataArray[i].duration))
                dataEntries.append(lightDataEntry)
                colorArray.append(UIColor(red: 136 / 255, green: 136 / 255, blue: 136 / 255, alpha: 1))
                
                //FFFF00
                //AWAKE: 0xFF FFFF00 (yellow)
                //DEEP: 0xFF 444444 (dark gray)
                //LIGHT: 0xFF 888888 (gray)
                
                secondOfLight += self.currentDataArray[i].duration
                
                if i == lastItem {
                    //let endTime = currentList[i+1].start_time
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    let startDate = dateFormatter.date(from: self.currentDataArray[i].start_time)
                    let endDate = startDate!.addingTimeInterval( TimeInterval(Int(self.currentDataArray[i].duration)) )
                    print(endDate)
                    let endTime = dateFormatter.string(from: endDate)
                    //print("end time=\(endTime)")
                    //let endTime = self.sleepInfoOne[i+1].start_time
                    print("endTime=\(endTime)")
                    let endTimeSepArray = endTime.components(separatedBy: "-")
                    let endTimeTmp: String = endTimeSepArray[1]
                    let endIndex = endTimeTmp.index(endTimeTmp.endIndex, offsetBy: -3)
                    let truncated = endTimeTmp.substring(to: endIndex)
                    self.endTimeLabel.text = truncated
                    //self.saveEndDate = endTimeSepArray[0]
                }
                
            } else if self.currentDataArray[i].sleep_state == 0 || self.currentDataArray[i].sleep_state == 4 {
                if i != lastItem {
                    let awakeDataEntry = BarChartDataEntry(x: Double(i),
                                                           y: Double(self.currentDataArray[i].duration))
                    dataEntries.append(awakeDataEntry)
                    colorArray.append(UIColor(red: 255 / 255, green: 255 / 255, blue: 0 / 255, alpha: 1))
                    secondOfAwake += self.currentDataArray[i].duration
                    
                    if i == lastItem {
                        print("Last item state != awake, show!")
                    }
                } else {
                    print("Last item state = awake, do not show!")
                    let endTime = self.currentDataArray[i].start_time
                    let endTimeSepArray = endTime.components(separatedBy: "-")
                    let endTimeTmp: String = endTimeSepArray[1]
                    let endIndex = endTimeTmp.index(endTimeTmp.endIndex, offsetBy: -3)
                    let truncated = endTimeTmp.substring(to: endIndex)
                    self.endTimeLabel.text = truncated
                    //self.saveEndDate = endTimeSepArray[0]
                }
            } else if self.currentDataArray[i].sleep_state == 1 {
                
                let deepDataEntry = BarChartDataEntry(x: Double(i),
                                                      y: Double(self.currentDataArray[i].duration))
                dataEntries.append(deepDataEntry)
                colorArray.append(UIColor(red: 68 / 255, green: 68 / 255, blue: 68 / 255, alpha: 1))
                secondOfDeep += self.currentDataArray[i].duration
                
                if i == lastItem {
                    //let endTime = currentList[i+1].start_time
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    let startDate = dateFormatter.date(from: self.currentDataArray[i].start_time)
                    let endDate = startDate!.addingTimeInterval( TimeInterval(Int(self.currentDataArray[i].duration)) )
                    print(endDate)
                    let endTime = dateFormatter.string(from: endDate)
                    //print("end time=\(endTime)")
                    //let endTime = self.sleepInfoOne[i+1].start_time
                    print("endTime=\(endTime)")
                    let endTimeSepArray = endTime.components(separatedBy: "-")
                    let endTimeTmp: String = endTimeSepArray[1]
                    let endIndex = endTimeTmp.index(endTimeTmp.endIndex, offsetBy: -3)
                    let truncated = endTimeTmp.substring(to: endIndex)
                    self.endTimeLabel.text = truncated
                    //self.saveEndDate = endTimeSepArray[0]
                }
                
            } else {
                // ???
            }
            
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Sleep Duration")
        let chartData = BarChartData(dataSet: chartDataSet)
        
        //chartDataSet.colors = [UIColor.yellow, UIColor.blue, UIColor.red, UIColor.yellow, UIColor.green, UIColor.red]
        chartDataSet.colors = colorArray
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
    }
    
    func getSleepListFromDatabase() -> Results<sleep> {
        do {
            let realm = try Realm()
            self.tmpList = realm.objects(sleep.self)
            self.sleepList = self.tmpList.sorted(byKeyPath: "start_time", ascending: true)
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
        print("hour")
        print(components.hour ?? 0)
        print("minute")
        print(components.minute ?? 0)
        print("second")
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
    
    func checkItemInRange(day: Date, itemTime: String) -> Bool {
        var startRangeOfDay = Date()
        var endRangeOfDay = Date()
        
        print("checkItemInRange() :: itemTime=\(itemTime)")
        print("checkItemInRange() :: day=\(day)  sleepStartTime=\(self.sleepStartTime) sleepEndTime=\(self.sleepEndTime)")
        
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
        //dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        
        let itemDate = dateFormatter.date(from: itemTime)!
        print("itemDate=\(itemDate)")
        
        if itemDate >= startRangeOfDay &&
            itemDate <= endRangeOfDay {
            print("The time is between \(resultOfStart) and \(resultOfEnd)")
            return true
        }
        return false
    }

    func processCreateDataMap(sourceData: Results<sleep>) -> [sleepDataStruct] {
        print("processCreateDataMap()!")
        self.sleepInfoArray.removeAll()
        self.sleepInfoOne.removeAll()
        self.sleepInfoTwo.removeAll()
        self.sleepInfoThree.removeAll()
        self.sleepInfoFour.removeAll()
        self.sleepInfoFive.removeAll()
        self.sleepInfoSix.removeAll()
        self.sleepInfoSeven.removeAll()
        self.dataMapDicts.removeAll()
        
        let today = Date()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: today)
        let year = components.year!
        let month = components.month!
        let day = components.day!
        
        let todayStr = String(format: "%04i/%02i/%02i", year, month, day)
        print("today=\(today) todayStr=\(todayStr)!")
        
        let yesterday = Date().yesterday
        let yesterdayStr = String(format: "%04i/%02i/%02i", yesterday.year, yesterday.month, yesterday.day)
        print("yesterday=\(yesterday) yesterdayStr=\(yesterdayStr)")
        
        let yester2day = Date().yester2day
        let yester2dayStr = String(format: "%04i/%02i/%02i", yester2day.year, yester2day.month, yester2day.day)
        print("yester2day=\(yester2day) yester2dayStr=\(yester2dayStr)")
        
        let yester3day = Date().yester3day
        let yester3dayStr = String(format: "%04i/%02i/%02i", yester3day.year, yester3day.month, yester3day.day)
        print("yester3day=\(yester3day) yester3dayStr=\(yester3dayStr)")
        
        let yester4day = Date().yester4day
        let yester4dayStr = String(format: "%04i/%02i/%02i", yester4day.year, yester4day.month, yester4day.day)
        print("yester4day=\(yester4day) yester4dayStr=\(yester4dayStr)")
        
        let yester5day = Date().yester5day
        let yester5dayStr = String(format: "%04i/%02i/%02i", yester5day.year, yester5day.month, yester5day.day)
        print("yester5day=\(yester5day) yester5dayStr=\(yester5dayStr)")
        
        let yester6day = Date().yester6day
        let yester6dayStr = String(format: "%04i/%02i/%02i", yester6day.year, yester6day.month, yester6day.day)
        print("yester6day=\(yester6day) yester6dayStr=\(yester6dayStr)")
        
        self.sleepInfoArray.append(todayStr)
        self.sleepInfoArray.append(yesterdayStr)
        self.sleepInfoArray.append(yester2dayStr)
        self.sleepInfoArray.append(yester3dayStr)
        self.sleepInfoArray.append(yester4dayStr)
        self.sleepInfoArray.append(yester5dayStr)
        self.sleepInfoArray.append(yester6dayStr)
        
        var duration: Int = 0
        var flag1 = 0
        var flag2 = 0
        var flag3 = 0
        var flag4 = 0
        var flag5 = 0
        var flag6 = 0
        var flag7 = 0
        
        for i in 0 ..< sourceData.count {
            let sleepItem = sourceData[i]
            
            // if sleepItem.start_time.range(of: today) != nil {
            if checkItemInRange(day: today, itemTime: sleepItem.start_time) {
                print("today start_time=\(sleepItem.start_time)")
                // AWAKE => 0 , 4
                // idle => 8 濾掉
                let nextIndex = i+1
                let state = sleepItem.sleep_state
                
                if flag1 == 0 {
                    if state != 0 && state != 4 && state != 8 {
                        flag1 = 1
                        if nextIndex < sourceData.count {
                            duration = computeDuration(sTime: sleepItem.start_time,
                                                       eTime: sourceData[nextIndex].start_time)
                        } else {
                            duration = 0
                        }
                        let item = sleepDataStruct(start_time: sleepItem.start_time,
                                                   duration: duration,
                                                   sleep_state: sleepItem.sleep_state)
                        self.sleepInfoOne.append(item)
                    }
                } else {
                    if nextIndex < sourceData.count {
                        duration = computeDuration(sTime: sleepItem.start_time,
                                                   eTime: sourceData[nextIndex].start_time)
                    } else {
                        duration = 0
                    }
                    let item = sleepDataStruct(start_time: sleepItem.start_time,
                                               duration: duration,
                                               sleep_state: sleepItem.sleep_state)
                    self.sleepInfoOne.append(item)
                }
            //} else if sleepItem.start_time.range(of: yesterday) != nil {
            } else if checkItemInRange(day: yesterday, itemTime: sleepItem.start_time) {
                print("yesterday start_time=\(sleepItem.start_time)")
                let nextIndex = i+1
                let state = sleepItem.sleep_state
                
                if flag2 == 0 {
                    if state != 0 && state != 4 && state != 8 {
                        flag2 = 1
                        if nextIndex < sourceData.count {
                            duration = computeDuration(sTime: sleepItem.start_time,
                                                       eTime: sourceData[nextIndex].start_time)
                        } else {
                            duration = 0
                        }
                        let item = sleepDataStruct(start_time: sleepItem.start_time,
                                                   duration: duration,
                                                   sleep_state: sleepItem.sleep_state)
                        self.sleepInfoTwo.append(item)
                    }
                } else {
                    if nextIndex < sourceData.count {
                        duration = computeDuration(sTime: sleepItem.start_time,
                                                   eTime: sourceData[nextIndex].start_time)
                    } else {
                        duration = 0
                    }
                    let item = sleepDataStruct(start_time: sleepItem.start_time,
                                               duration: duration,
                                               sleep_state: sleepItem.sleep_state)
                    self.sleepInfoTwo.append(item)
                }
            //} else if sleepItem.start_time.range(of: yester2day) != nil {
            } else if checkItemInRange(day: yester2day, itemTime: sleepItem.start_time) {
                print("yester2day start_time=\(sleepItem.start_time)")
                let nextIndex = i+1
                let state = sleepItem.sleep_state
                
                if flag3 == 0 {
                    if state != 0 && state != 4 && state != 8 {
                        flag3 = 1
                        if nextIndex < sourceData.count {
                            duration = computeDuration(sTime: sleepItem.start_time,
                                                       eTime: sourceData[nextIndex].start_time)
                        } else {
                            duration = 0
                        }
                        let item = sleepDataStruct(start_time: sleepItem.start_time,
                                                   duration: duration,
                                                   sleep_state: sleepItem.sleep_state)
                        self.sleepInfoThree.append(item)
                    }
                } else {
                    if nextIndex < sourceData.count {
                        duration = computeDuration(sTime: sleepItem.start_time,
                                                   eTime: sourceData[nextIndex].start_time)
                    } else {
                        duration = 0
                    }
                    let item = sleepDataStruct(start_time: sleepItem.start_time,
                                               duration: duration,
                                               sleep_state: sleepItem.sleep_state)
                    self.sleepInfoThree.append(item)
                }
            //} else if sleepItem.start_time.range(of: yester3day) != nil {
            } else if checkItemInRange(day: yester3day, itemTime: sleepItem.start_time) {
                print("yester3day start_time=\(sleepItem.start_time)")
                let nextIndex = i+1
                let state = sleepItem.sleep_state
                
                if flag4 == 0 {
                    if state != 0 && state != 4 && state != 8 {
                        flag4 = 1
                        if nextIndex < sourceData.count {
                            duration = computeDuration(sTime: sleepItem.start_time,
                                                       eTime: sourceData[nextIndex].start_time)
                        } else {
                            duration = 0
                        }
                        let item = sleepDataStruct(start_time: sleepItem.start_time,
                                                   duration: duration,
                                                   sleep_state: sleepItem.sleep_state)
                        self.sleepInfoFour.append(item)
                    }
                } else {
                    if nextIndex < sourceData.count {
                        duration = computeDuration(sTime: sleepItem.start_time,
                                                   eTime: sourceData[nextIndex].start_time)
                    } else {
                        duration = 0
                    }
                    let item = sleepDataStruct(start_time: sleepItem.start_time,
                                               duration: duration,
                                               sleep_state: sleepItem.sleep_state)
                    self.sleepInfoFour.append(item)
                }
            //} else if sleepItem.start_time.range(of: yester4day) != nil {
            } else if checkItemInRange(day: yester4day, itemTime: sleepItem.start_time) {
                print("yester4day start_time=\(sleepItem.start_time)")
                let nextIndex = i+1
                let state = sleepItem.sleep_state
                
                if flag5 == 0 {
                    if state != 0 && state != 4 && state != 8 {
                        flag5 = 1
                        if nextIndex < sourceData.count {
                            duration = computeDuration(sTime: sleepItem.start_time,
                                                       eTime: sourceData[nextIndex].start_time)
                        } else {
                            duration = 0
                        }
                        let item = sleepDataStruct(start_time: sleepItem.start_time,
                                                   duration: duration,
                                                   sleep_state: sleepItem.sleep_state)
                        self.sleepInfoFive.append(item)
                    }
                } else {
                    if nextIndex < sourceData.count {
                        duration = computeDuration(sTime: sleepItem.start_time,
                                                   eTime: sourceData[nextIndex].start_time)
                    } else {
                        duration = 0
                    }
                    let item = sleepDataStruct(start_time: sleepItem.start_time,
                                               duration: duration,
                                               sleep_state: sleepItem.sleep_state)
                    self.sleepInfoFive.append(item)
                }
            //} else if sleepItem.start_time.range(of: yester5day) != nil {
            } else if checkItemInRange(day: yester5day, itemTime: sleepItem.start_time) {
                print("yester5day start_time=\(sleepItem.start_time)")
                let nextIndex = i+1
                let state = sleepItem.sleep_state
                
                if flag6 == 0 {
                    if state != 0 && state != 4 && state != 8 {
                        flag6 = 1
                        if nextIndex < sourceData.count {
                            duration = computeDuration(sTime: sleepItem.start_time,
                                                       eTime: sourceData[nextIndex].start_time)
                        } else {
                            duration = 0
                        }
                        let item = sleepDataStruct(start_time: sleepItem.start_time,
                                                   duration: duration,
                                                   sleep_state: sleepItem.sleep_state)
                        self.sleepInfoSix.append(item)
                    }
                } else {
                    if nextIndex < sourceData.count {
                        duration = computeDuration(sTime: sleepItem.start_time,
                                                   eTime: sourceData[nextIndex].start_time)
                    } else {
                        duration = 0
                    }
                    let item = sleepDataStruct(start_time: sleepItem.start_time,
                                               duration: duration,
                                               sleep_state: sleepItem.sleep_state)
                    self.sleepInfoSix.append(item)
                }
            //} else if sleepItem.start_time.range(of: yester6day) != nil {
            } else if checkItemInRange(day: yester6day, itemTime: sleepItem.start_time) {
                print("yester6day start_time=\(sleepItem.start_time)")
                let nextIndex = i+1
                let state = sleepItem.sleep_state
                
                if flag7 == 0 {
                    if state != 0 && state != 4 && state != 8 {
                        flag7 = 1
                        if nextIndex < sourceData.count {
                            duration = computeDuration(sTime: sleepItem.start_time,
                                                       eTime: sourceData[nextIndex].start_time)
                        } else {
                            duration = 0
                        }
                        let item = sleepDataStruct(start_time: sleepItem.start_time,
                                                   duration: duration,
                                                   sleep_state: sleepItem.sleep_state)
                        self.sleepInfoSeven.append(item)
                    }
                } else {
                    if nextIndex < sourceData.count {
                        duration = computeDuration(sTime: sleepItem.start_time,
                                                   eTime: sourceData[nextIndex].start_time)
                    } else {
                        duration = 0
                    }
                    let item = sleepDataStruct(start_time: sleepItem.start_time,
                                               duration: duration,
                                               sleep_state: sleepItem.sleep_state)
                    self.sleepInfoSeven.append(item)
                }
            }
        }
        
        self.dataMapDicts[0] = self.sleepInfoOne
        self.dataMapDicts[1] = self.sleepInfoTwo
        self.dataMapDicts[2] = self.sleepInfoThree
        self.dataMapDicts[3] = self.sleepInfoFour
        self.dataMapDicts[4] = self.sleepInfoFive
        self.dataMapDicts[5] = self.sleepInfoSix
        self.dataMapDicts[6] = self.sleepInfoSeven
        
        return self.sleepInfoOne

    }
    
    func updateUI() {
        if self.currentDataArray.count > 0 {
            let separatedArray = self.currentDataArray[0].start_time.components(separatedBy: "-")
            let startTimeTmp: String = separatedArray[1]
            let endIndex = startTimeTmp.index(startTimeTmp.endIndex, offsetBy: -3)
            let truncated = startTimeTmp.substring(to: endIndex)
            //var name: String = "Dolphin"
            //let endIndex = name.index(name.endIndex, offsetBy: -2)
            //let truncated = name.substring(to: endIndex)
            //print(name)      // "Dolphin"
            //print(truncated) // "Dolph"
            self.startTimeLabel.text = truncated

            let deepDurationArray = DateUtils.timeIntArray(time: TimeInterval(Int(self.secondOfDeep)))
            let lightDurationArray = DateUtils.timeIntArray(time: TimeInterval(Int(self.secondOfLight)))
            let inBedSecond = self.secondOfDeep + self.secondOfLight
            let inBedDurationArray = DateUtils.timeIntArray(time: TimeInterval(Int(inBedSecond)))
            let awakeDurationArray = DateUtils.timeIntArray(time: TimeInterval(Int(self.secondOfAwake)))
            
            self.inBedForLabel.text = "\(inBedDurationArray[0])" + self.hourStr + "\(inBedDurationArray[1])" + self.minStr
            self.deepSleepLabel.text = "\(deepDurationArray[0])" + self.hourStr + "\(deepDurationArray[1])" + self.minStr
            self.lightSleepLabel.text = "\(lightDurationArray[0])" + self.hourStr + "\(lightDurationArray[1])" + self.minStr
            self.fellAsleepLabel.text = self.startTimeLabel.text
            self.wokeUpLabel.text = self.endTimeLabel.text
            self.awakeTimeLabel.text = "\(awakeDurationArray[0])" + self.hourStr + "\(awakeDurationArray[1])" + self.minStr
            
            // check if yesterday
            if (self.currentDayIndex == 0) {
                let startTimeStr = self.startTimeLabel.text!
                let endTimeStr = self.endTimeLabel.text!
                
                let inBedForString = "\(inBedDurationArray[0])" + "-" + "\(inBedDurationArray[1])" + "-" + "(\(startTimeStr)~\(endTimeStr))"
                
                print("inBedForString=\(inBedForString)")
                
                let deepStr = "\(deepDurationArray[0])" + "-" + "\(deepDurationArray[1])"
                let lightStr = "\(lightDurationArray[0])" + "-" + "\(lightDurationArray[1])"
                
                UserDefaults.standard.set(inBedForString, forKey: UserDefaultsKey.InBedForTime)
                UserDefaults.standard.set(deepStr, forKey: UserDefaultsKey.DeepSleepTime)
                UserDefaults.standard.set(lightStr, forKey: UserDefaultsKey.LightSleepTime)
                UserDefaults.standard.set(separatedArray[0], forKey: UserDefaultsKey.SleepDate)
            }
  
        } else {
            self.startTimeLabel.text = "00:00"
            self.endTimeLabel.text = "00:00"
            self.inBedForLabel.text = "0" + self.hourStr + "0" + self.minStr
            self.deepSleepLabel.text = "0" + self.hourStr + "0" + self.minStr
            self.lightSleepLabel.text = "0" + self.hourStr + "0" + self.minStr
            self.fellAsleepLabel.text = self.startTimeLabel.text
            self.wokeUpLabel.text = self.endTimeLabel.text
            self.awakeTimeLabel.text = "0" + self.hourStr + "0" + self.minStr
            
            // check if yesterday
            if (self.currentDayIndex == 0) {
                let inBedForString = "0" + "-" + "0" + "-" + "00:00~00:00"
                UserDefaults.standard.set(inBedForString, forKey: UserDefaultsKey.InBedForTime)
                UserDefaults.standard.set("0-0", forKey: UserDefaultsKey.DeepSleepTime)
                UserDefaults.standard.set("0-0", forKey: UserDefaultsKey.LightSleepTime)
                UserDefaults.standard.set("0", forKey: UserDefaultsKey.SleepDate)
            }
            
        }
    
    }
    
    func useCurrentListThenUpdateUI(index: Int) {
        if self.dataMapDicts[index] != nil {
            let currentList = self.dataMapDicts[index]!
            updateChartWithData(currentList: currentList, dayIndex: index)
        } else {
            let currentList = [sleepDataStruct]()
            updateChartWithData(currentList: currentList, dayIndex: index)
        }
        // update UI
        updateUI()
    }
    
    func reloadDataThenUpdateUI() {
        
        let sleepList = getSleepListFromDatabase()
        
        //print("======")
        //for i in 0..<sleepList.count {
        //    print(sleepList[i].start_time)
        //}
        //print("======")
        
        
        let todayList = self.processCreateDataMap(sourceData: sleepList)
        // update chart
        self.currentDayIndex = 0
        updateChartWithData(currentList: todayList, dayIndex: self.currentDayIndex)
        // update UI
        updateUI()
    }
    
}

// MARK: axisFormatDelegate
extension SleepHistoryVC: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        /*
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm.ss"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
        */
        return ""
    }
}

extension SleepHistoryVC: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("\(Int(entry.x)), \(entry.y)")
        let startTime = self.currentDataArray[Int(entry.x)].start_time
        let nextIndex = Int(entry.x + 1)
        var showText = ""
        let separatedStartTime = startTime.components(separatedBy: "-")
        //  0 1 2 3 4 : count = 5
        if self.currentDataArray.count <= nextIndex {
            // showText = separatedStartTime[1]
            if let endTime = self.endTimeLabel.text {
                showText = "\(separatedStartTime[1]) ~ \(endTime):00"
            }
        } else {
            let nextTime = self.currentDataArray[nextIndex].start_time
            let separatedNextTime = nextTime.components(separatedBy: "-")
            showText = "\(separatedStartTime[1]) ~ \(separatedNextTime[1])"
        }
        
        let sleepState = self.currentDataArray[Int(entry.x)].sleep_state
        /*
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fromDate = txDate
        let toDate = dateFormatter.string(from: dateFormatter.date(from: fromDate)!.addingTimeInterval(1 * 24 * 60 * 60))
        let date = startDate.addingTimeInterval(5.0 * 60.0)
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .minute, value: 5, to: startDate)
        */
        self.noteLabel.text = "\(SleepState.init(rawValue: sleepState)!.stateString()), \(showText)"
    }
}

