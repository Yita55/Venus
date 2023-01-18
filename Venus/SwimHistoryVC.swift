//
//  SwimHistoryVC.swift
//  Venus
//
//  Created by Kenneth on 2017/Aug/13.
//  Copyright © 2017年 ADA. All rights reserved.
//

import UIKit
import RealmSwift
import Charts
import EZAlertController

struct swimDataStruct {
    var start_time: String
    var end_time: String
    var stroke_type: Int
    var stroke_count: Int
    var section_num: Int
    var pool_size: Int
    var lap_num: Int
    var swimDuration: Int
    var cal: Int
}

class SwimHistoryVC: UIViewController {
    var childScrollView: UIScrollView {
        return tableView
    }
    
    var goingUp: Bool?
    var childScrollingDownDueToParent = false
    var tmpList: Results<swim>!
    var swimList: Results<swim>!
    var btDataModel = BTDataModel.sharedInstance
    weak var axisFormatDelegate: IAxisValueFormatter?
    var swimDataOne = [swimDataStruct]()
    var swimDataTwo = [swimDataStruct]()
    var swimDataThree = [swimDataStruct]()
    var swimDataFour = [swimDataStruct]()
    var swimDataFive = [swimDataStruct]()
    var swimDataSix = [swimDataStruct]()
    var swimDataSeven = [swimDataStruct]()
    var dataMapDicts = [Int : [swimDataStruct]]()
    var currentDayIndex = 0
    var dayArray = [String]()
    var currentDataArray = [swimDataStruct]()
    var totalTime: Int = 0
    var totalCalorie: Int = 0
    var totalDistance: Double = 0
    var chartDict = [Int : swimDataStruct]()
    var plistManager = PlistManager()
    var heightIntValue: Int = 0
    var weightIntValue: Int = 0
    var ageIntValue: Int = 0
    var genderValue: String = ""
    var swimPoolSizeValue: String = ""
    var strokeTypeDict = [0 : PropertyUtils.readLocalizedProperty("swim_unknown_stroke"),
                          1 : PropertyUtils.readLocalizedProperty("swim_freestyle"),
                          2 : PropertyUtils.readLocalizedProperty("swim_backstroke"),
                          3 : PropertyUtils.readLocalizedProperty("swim_breaststroke"),
                          4 : PropertyUtils.readLocalizedProperty("swim_butterfly"),
                          5 : PropertyUtils.readLocalizedProperty("swim_breaststroke")]
    var strokeTypeEnglishDict = [0 : "Others",
                                 1 : "FREESTYLE",
                                 2 : "BACKSTROKE",
                                 3 : "BREASTSTROKE",
                                 4 : "BUTTERFLY",
                                 5 : "BREASTSTROKE"]
    var sectionDictDataOne = [Int : [swimDataStruct]]()
    var sectionDictDataTwo = [Int : [swimDataStruct]]()
    var sectionDictDataThree = [Int : [swimDataStruct]]()
    var sectionDictDataFour = [Int : [swimDataStruct]]()
    var sectionDictDataFive = [Int : [swimDataStruct]]()
    var sectionDictDataSix = [Int : [swimDataStruct]]()
    var sectionDictDataSeven = [Int : [swimDataStruct]]()
    var sectionDataMapDicts = [Int : [Int : [swimDataStruct]]]()
    var currentSectionDataArray = [Int : [swimDataStruct]]()
    let font18 = UIFont.systemFontOfSizeByScreenWidth(375.0, fontSize: 18.0)
    let font14 = UIFont.systemFontOfSizeByScreenWidth(375.0, fontSize: 14.0)
    let blodFont18 = UIFont.boldSystemFontOfSizeByScreenWidth(375.0, fontSize: 18.0)
    
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var parentScrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var totalCalLabel: UILabel!
    
    @IBAction func refreshButtonTap(_ sender: AnyObject) {
        if btDataModel.btConnectedPeripheral == nil {
            EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"), message: PropertyUtils.readLocalizedProperty("no_device_bonded"), acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
                print("cliked OK")
                //let swimList = self.getSwimListFromDatabase()
                //self.reloadDataThenUpdateUI()
            }
        } else {
            //====== connected device, start to sync ...
            btDataModel.isSyncAll = false
            btDataModel.queryHistoryOfSwimFD()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(SwimHistoryVC.reloadDataThenUpdateUI), name: NSNotification.Name(rawValue: kSyncSwimComplete), object: nil)
        
        parentScrollView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = true
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        axisFormatDelegate = self
        self.barChartView.delegate = self
        
        self.totalCalLabel.font = blodFont18
        self.totalTimeLabel.font = blodFont18
        self.totalDistanceLabel.font = blodFont18
        
        if btDataModel.btConnectedPeripheral == nil {
            EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"), message: PropertyUtils.readLocalizedProperty("no_device_bonded"), acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
                print("cliked OK")
#if false
                let swimList = self.getSwimListFromDatabase()
    
                if swimList.count == 0 {
                    // Others = 0,
                    // FRONTCRAWL = 1
                    // BACKSTROKE = 2
                    // BREASTSTROKE = 3
                    // BUTTERFLY = 4
                    // HEADUPBREAST = 5 => show 3
                    self.btDataModel.insertToDB_0xFD(startTime: "2017/12/01-07:24:10",
                                                     endTime: "2017/12/01-07:24:35", strokeType: 1, strokeCount: 54, sectionNumber: 1, poolSize: 0, lapNumber: 1, duration: 36)
                    
                    self.btDataModel.insertToDB_0xFD(startTime: "2017/12/01-07:24:49",
                                                     endTime: "2017/12/01-07:25:15", strokeType: 3, strokeCount: 33, sectionNumber: 1, poolSize: 0, lapNumber: 2, duration: 46)
                    
                    /*
                    self.btDataModel.insertToDB_0xFD(startTime: "2017/11/29-07:15:03",
                                                     endTime: "2017/11/29-07:15:55", strokeType: 2, strokeCount: 40, sectionNumber: 1, poolSize: 0, lapNumber: 3, duration: 52)
                    
                    self.btDataModel.insertToDB_0xFD(startTime: "2017/11/29-07:15:55",
                                                     endTime: "2017/11/29-07:16:42", strokeType: 3, strokeCount: 39, sectionNumber: 1, poolSize: 0, lapNumber: 4, duration: 200)
                    
                    self.btDataModel.insertToDB_0xFD(startTime: "2017/11/29-07:16:42",
                                                     endTime: "2017/11/29-07:17:15", strokeType: 4, strokeCount: 52, sectionNumber: 1, poolSize: 0, lapNumber: 5, duration: 200)
                    
                    //======
                    self.btDataModel.insertToDB_0xFD(startTime: "2017/11/29-07:17:15",
                                                     endTime: "2017/11/29-07:18:01", strokeType: 3, strokeCount: 55, sectionNumber: 1, poolSize: 0, lapNumber: 6, duration: 800)
                    
                    self.btDataModel.insertToDB_0xFD(startTime: "2017/11/29-07:18:01",
                                                     endTime: "2017/11/29-07:18:53", strokeType: 2, strokeCount: 49, sectionNumber: 1, poolSize: 0, lapNumber: 7, duration: 400)
                    
                    self.btDataModel.insertToDB_0xFD(startTime: "2017/11/29-07:18:53",
                                                     endTime: "2017/11/29-07:19:24", strokeType: 4, strokeCount: 31, sectionNumber: 1, poolSize: 0, lapNumber: 8, duration: 400)
                    
                    self.btDataModel.insertToDB_0xFD(startTime: "2017/11/29-07:19:24",
                                                     endTime: "2017/11/29-07:20:01", strokeType: 4, strokeCount: 42, sectionNumber: 1, poolSize: 0, lapNumber: 9, duration: 200)
                    
                    self.btDataModel.insertToDB_0xFD(startTime: "2017/11/29-07:20:01",
                                                     endTime: "2017/11/29-07:20:39", strokeType: 3, strokeCount: 48, sectionNumber: 1, poolSize: 0, lapNumber: 10, duration: 800)

                    self.btDataModel.insertToDB_0xFD(startTime: "2017/11/29-07:21:39",
                                                     endTime: "2017/11/29-07:23:39", strokeType: 4, strokeCount: 55, sectionNumber: 2, poolSize: 0, lapNumber: 1, duration: 1200)
                    
                    self.btDataModel.insertToDB_0xFD(startTime: "2017/11/29-07:24:44",
                                                     endTime: "2017/11/29-07:25:39", strokeType: 3, strokeCount: 44, sectionNumber: 2, poolSize: 0, lapNumber: 2, duration: 1200)
                    
                    self.btDataModel.insertToDB_0xFD(startTime: "2017/11/29-07:26:44",
                                                     endTime: "2017/11/29-07:27:29", strokeType: 2, strokeCount: 33, sectionNumber: 2, poolSize: 0, lapNumber: 3, duration: 1200)
                    */
                    
                }
#endif
                self.reloadDataThenUpdateUI()
            }
        } else {
            //====== connected device, start to sync ...
            btDataModel.isSyncAll = false
            btDataModel.queryHistoryOfSwimFD()
        }
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.AlreadyOpenSetting) == true {
            if let plistManager = SharingManager.sharedInstance.plistManager {
                self.plistManager = plistManager
                self.heightIntValue = Int(self.plistManager.getCellContent(key: "height"))!
                self.weightIntValue = Int(self.plistManager.getCellContent(key: "weight"))!
                let age = UserDefaults.standard.string(forKey: UserDefaultsKey.Age)!
                self.ageIntValue = Int(age)!
                self.genderValue = self.plistManager.getCellContent(key: "gender")
                self.swimPoolSizeValue = self.plistManager.getCellContent(key: "swim_pool_size")
                print(self.heightIntValue)
                print(self.weightIntValue)
                print(self.ageIntValue)
                print(self.genderValue)
                print(self.swimPoolSizeValue)
            }
        } else {
            print("First open swimViewControllr!")
            if self.plistManager.openPlist() == true {
                print("plist openPlist == true!")
                self.heightIntValue = Int(self.plistManager.getCellContent(key: "height"))!
                self.weightIntValue = Int(self.plistManager.getCellContent(key: "weight"))!
                
                let age = UserDefaults.standard.string(forKey: UserDefaultsKey.Age)!
                self.ageIntValue = Int(age)!
                
                self.genderValue = self.plistManager.getCellContent(key: "gender")
                self.swimPoolSizeValue = self.plistManager.getCellContent(key: "swim_pool_size")
                print(self.heightIntValue)
                print(self.weightIntValue)
                print(self.ageIntValue)
                print(self.genderValue)
                print(self.swimPoolSizeValue)
                
            } else {
                let stepGoal = UserDefaults.standard.string(forKey: UserDefaultsKey.StepsGoal)!
                let height = UserDefaults.standard.string(forKey: UserDefaultsKey.Height)!
                let weight = UserDefaults.standard.string(forKey: UserDefaultsKey.Weight)!
                let age = UserDefaults.standard.string(forKey: UserDefaultsKey.Age)!
                
                print("stepGoal=\(String(describing: stepGoal))")
                print("height=\(String(describing: height))")
                print("weight=\(String(describing: weight))")
                print("age=\(String(describing: age))")
                
                self.heightIntValue = Int(height)!
                self.weightIntValue = Int(weight)!
                self.ageIntValue = Int(age)!
                self.genderValue = "male"
                self.swimPoolSizeValue = "25m"
            }
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
    
    func updateChartWithData(currentList: [swimDataStruct], dayIndex: Int) {
        self.currentDataArray = currentList
        self.chartDict.removeAll()

        self.totalTime = 0
        self.totalDistance = 0
        self.totalCalorie = 0
        
        var dataEntries: [BarChartDataEntry] = []
        
        self.lastTimeLabel.text = self.dayArray[dayIndex]
        
        if currentList.count > 0 {
            self.noteLabel.text = ""
        } else {
            self.noteLabel.text = PropertyUtils.readLocalizedProperty("no data")
            
            let chartDataSet = BarChartDataSet(values: dataEntries, label: "Swim Duration")
            let chartData = BarChartData(dataSet: chartDataSet)
            chartDataSet.colors =  [UIColor.blue]
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
            
            self.tableView.reloadData()
            self.tableView.tableFooterView = UIView(frame: CGRect.zero)

            return
        }
        
        //var colorArray = [UIColor]()
        
        // Others = 0,
        // FRONTCRAWL = 1
        // BACKSTROKE = 2
        // BREASTSTROKE = 3
        // BUTTERFLY = 4
        // HEADUPBREAST = 5
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd-HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let fromDate = "\(self.dayArray[dayIndex])-00:00:00"
        
        var fDate = dateFormatter.date(from: fromDate)!
        var eDate: Date?
        
        for i in 0..<144 {
            eDate = fDate.addingTimeInterval(600)
            print("\(fDate) \(eDate!)")
            for j in 0..<currentList.count {
                print("\(currentList[j].start_time)")
                self.currentDataArray[j].swimDuration = computeDurationInt(sTime: currentList[j].start_time, eTime: currentList[j].end_time)
                let startTime = dateFormatter.date(from: currentList[j].start_time)
                
                if checkInTimeRange(sDate: fDate, eDate: eDate!, checkDate: startTime!) == true {
                    let swimDataEntry = BarChartDataEntry(x: Double(i),
                                                          y: Double(self.currentDataArray[j].swimDuration))
                    dataEntries.append(swimDataEntry)
                    self.chartDict[i] = currentList[j]
                    self.totalTime += self.currentDataArray[j].swimDuration
                    //  都換成公尺
                    self.totalDistance += computeDistanceDoubleValue(pool_size: currentList[j].pool_size)
                    self.totalCalorie += computeCalIntValue(strokeState: currentList[j].stroke_type, durationSecond: Double(self.currentDataArray[j].swimDuration) / 60.0)
                } else {
                    let zeroDataEntry = BarChartDataEntry(x: Double(i),
                                                          y: 0.0)
                    dataEntries.append(zeroDataEntry)
                }
            }
            fDate = eDate!
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Swim Duration")
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
        
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func getSwimListFromDatabase() -> Results<swim> {
        do {
            let realm = try Realm()
            self.tmpList = realm.objects(swim.self)
            self.swimList = self.tmpList.sorted(byKeyPath: "start_time", ascending: true)
            //self.swimList = realm.objects(swim.self)
            //return realm.objects(swim.self)
            return self.swimList
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func processCreateDataMap(sourceData: Results<swim>) -> [swimDataStruct] {
        self.dayArray.removeAll()
        self.swimDataOne.removeAll()
        self.swimDataTwo.removeAll()
        self.swimDataThree.removeAll()
        self.swimDataFour.removeAll()
        self.swimDataFive.removeAll()
        self.swimDataSix.removeAll()
        self.swimDataSeven.removeAll()
        self.dataMapDicts.removeAll()
        
        self.sectionDictDataOne.removeAll()
        self.sectionDictDataTwo.removeAll()
        self.sectionDictDataThree.removeAll()
        self.sectionDictDataFour.removeAll()
        self.sectionDictDataFive.removeAll()
        self.sectionDictDataSix.removeAll()
        self.sectionDictDataSeven.removeAll()
        self.sectionDataMapDicts.removeAll()
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
            let item = swimDataStruct(start_time: sourceData[i].start_time,
                                      end_time: sourceData[i].end_time,
                                      stroke_type: sourceData[i].stroke_type,
                                      stroke_count: sourceData[i].stroke_count,
                                      section_num: sourceData[i].section_num,
                                      pool_size: sourceData[i].pool_size,
                                      lap_num: sourceData[i].lap_num,
                                      swimDuration: computeDurationInt(sTime: sourceData[i].start_time, eTime: sourceData[i].end_time),
                                      cal: computeCalIntValue(strokeState: sourceData[i].stroke_type, durationSecond: Double(computeDurationInt(sTime: sourceData[i].start_time, eTime: sourceData[i].end_time))/60.0))
            
            /*
            
                if sectionDict[i] != nil {
                    print("not nil")
                    var strArray = testdict[i]
                    let newDate = "string3"
                    strArray?.append(newDate)
                    
                    testdict[i] = strArray
                    
                } else {
                    testdict[i] = ["string1", "string2"]
                }
            */
            print(sourceData[i].start_time)
            if sourceData[i].start_time.range(of: today) != nil {
                print("Today")
                
                self.swimDataOne.append(item)
                
                if sectionDictDataOne[item.section_num] != nil {
                    var tmpSwimData = sectionDictDataOne[item.section_num]
                    
                    tmpSwimData?.append(item)
                    sectionDictDataOne[item.section_num] = tmpSwimData
                } else {
                    sectionDictDataOne[item.section_num] = [item]
                }
                
                
            } else if sourceData[i].start_time.range(of: yesterday) != nil {
                print("yesterday")
                
                self.swimDataTwo.append(item)
                
                if sectionDictDataTwo[item.section_num] != nil {
                    var tmpSwimData = sectionDictDataTwo[item.section_num]
                    
                    tmpSwimData?.append(item)
                    sectionDictDataTwo[item.section_num] = tmpSwimData
                } else {
                    sectionDictDataTwo[item.section_num] = [item]
                }
                
            } else if sourceData[i].start_time.range(of: yester2day) != nil {
                print("yester 2 day")
                
                self.swimDataThree.append(item)
                
                if sectionDictDataThree[item.section_num] != nil {
                    var tmpSwimData = sectionDictDataThree[item.section_num]
                    
                    tmpSwimData?.append(item)
                    sectionDictDataThree[item.section_num] = tmpSwimData
                } else {
                    sectionDictDataThree[item.section_num] = [item]
                }
                
            } else if sourceData[i].start_time.range(of: yester3day) != nil {
                print("yester 3 day")
                
                self.swimDataFour.append(item)
                
                if sectionDictDataFour[item.section_num] != nil {
                    var tmpSwimData = sectionDictDataFour[item.section_num]
                    
                    tmpSwimData?.append(item)
                    sectionDictDataFour[item.section_num] = tmpSwimData
                } else {
                    sectionDictDataFour[item.section_num] = [item]
                }
                
            } else if sourceData[i].start_time.range(of: yester4day) != nil {
                print("yester 4 day")
                
                self.swimDataFive.append(item)
                
                if sectionDictDataFive[item.section_num] != nil {
                    var tmpSwimData = sectionDictDataFive[item.section_num]
                    
                    tmpSwimData?.append(item)
                    sectionDictDataFive[item.section_num] = tmpSwimData
                } else {
                    sectionDictDataFive[item.section_num] = [item]
                }
                
            } else if sourceData[i].start_time.range(of: yester5day) != nil {
                print("yester 5 day")
                
                self.swimDataSix.append(item)
                
                if sectionDictDataSix[item.section_num] != nil {
                    var tmpSwimData = sectionDictDataSix[item.section_num]
                    
                    tmpSwimData?.append(item)
                    sectionDictDataSix[item.section_num] = tmpSwimData
                } else {
                    sectionDictDataSix[item.section_num] = [item]
                }
                
            } else if sourceData[i].start_time.range(of: yester6day) != nil {
                print("yester 6 day")
                
                self.swimDataSeven.append(item)
                
                if sectionDictDataSeven[item.section_num] != nil {
                    var tmpSwimData = sectionDictDataSeven[item.section_num]
                    
                    tmpSwimData?.append(item)
                    sectionDictDataSeven[item.section_num] = tmpSwimData
                } else {
                    sectionDictDataSeven[item.section_num] = [item]
                }
                
            }
        }
        
        self.dataMapDicts[0] = self.swimDataOne
        self.dataMapDicts[1] = self.swimDataTwo
        self.dataMapDicts[2] = self.swimDataThree
        self.dataMapDicts[3] = self.swimDataFour
        self.dataMapDicts[4] = self.swimDataFive
        self.dataMapDicts[5] = self.swimDataSix
        self.dataMapDicts[6] = self.swimDataSeven
        
        self.sectionDataMapDicts[0] = self.sectionDictDataOne
        self.sectionDataMapDicts[1] = self.sectionDictDataTwo
        self.sectionDataMapDicts[2] = self.sectionDictDataThree
        self.sectionDataMapDicts[3] = self.sectionDictDataFour
        self.sectionDataMapDicts[4] = self.sectionDictDataFive
        self.sectionDataMapDicts[5] = self.sectionDictDataSix
        self.sectionDataMapDicts[6] = self.sectionDictDataSeven
        
        return self.swimDataOne
        
    }
    
    func updateUI() {
        self.startTimeLabel.text = "00:00"
        self.endTimeLabel.text = "23:59"
        
        //self.totalDistance = 1200.0
        
        var poolUnit = ""
        let unitLengthValue = self.plistManager.getCellContent(key: "units_length")
        print("unitLengthValue=\(unitLengthValue)")
        
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.locale = Locale(identifier: "en_US")
        measurementFormatter.unitOptions = .providedUnit
        measurementFormatter.numberFormatter.maximumFractionDigits = 1
        measurementFormatter.unitStyle = .long
        
        var localizedString: String = ""
        if unitLengthValue == "cm/km" {
            // total_distance_unit_km = "公里";
            poolUnit = PropertyUtils.readLocalizedProperty("total_distance_unit_km")
            let meters: Double = self.totalDistance
            localizedString = measurementFormatter.string(from: Measurement(value: meters.metersToKm, unit: UnitLength.kilometers))
            print("km localizedString=\(localizedString)!")
            
        } else {
            // total_distance_unit_mile = "英哩”;
            poolUnit = PropertyUtils.readLocalizedProperty("total_distance_unit_mile")
            let meters: Double = self.totalDistance
            localizedString = measurementFormatter.string(from: Measurement(value: meters.metersToMi, unit: UnitLength.miles))
            print("miles localizedString=\(localizedString)!")
        }

        let totalDistance: String = localizedString.components(separatedBy: " ")[0]
        
        if self.currentDataArray.count > 0 {
            self.totalTimeLabel.text = DateUtils.timeString(time: TimeInterval(self.totalTime))
            self.totalDistanceLabel.text = "\(totalDistance) " + poolUnit
            self.totalCalLabel.text = "\(self.totalCalorie) " + PropertyUtils.readLocalizedProperty("calorie_k_unit")
        } else {
            self.totalTimeLabel.text = "00:00:00"
            self.totalDistanceLabel.text = "0.0 " + poolUnit
            self.totalCalLabel.text = "0 " + PropertyUtils.readLocalizedProperty("calorie_k_unit")
        }
    }
    
    func useCurrentListThenUpdateUI(index: Int) {
        if self.dataMapDicts[index] != nil {
            let currentList = self.dataMapDicts[index]!
            self.currentSectionDataArray = self.sectionDataMapDicts[index]!
        
            updateChartWithData(currentList: currentList, dayIndex: index)
        } else {
            let currentList = [swimDataStruct]()
            self.currentSectionDataArray = [Int : [swimDataStruct]]()
            
            updateChartWithData(currentList: currentList, dayIndex: index)
        }
        // update UI
        updateUI()
    }
    
    func reloadDataThenUpdateUI() {
        
        let swimList = getSwimListFromDatabase()
        
        let todayList = self.processCreateDataMap(sourceData: swimList)
        self.currentSectionDataArray = self.sectionDataMapDicts[0]!
        
        // update chart
        updateChartWithData(currentList: todayList, dayIndex: 0)
        // update UI
        updateUI()
    }
    
    func computeDuration(sTime: String, eTime: String) -> String {
        var durationHourStr = ""
        var durationMinuteStr = ""
        var durationSecondStr = ""
        //let date1Str = "2017/11/13-10:10:10"
        //let date2Str = "2017/11/13-12:10:1"
        
        let dateFormatterX = DateFormatter()
        dateFormatterX.dateFormat = "yyyy/MM/dd-HH:mm:ss"
        dateFormatterX.timeZone = TimeZone(secondsFromGMT: 0)
        let sDate = dateFormatterX.date(from: sTime)
        let eDate = dateFormatterX.date(from: eTime)
        
        //let calendar = NSCalendar.current
        //let unitFlags:NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month , NSCalendar.Unit.day , NSCalendar.Unit.hour , NSCalendar.Unit.minute , NSCalendar.Unit.second]
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
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
            durationHourStr = "\(components.hour!)\(PropertyUtils.readLocalizedProperty("timepicker_hour"))"
        }
        if components.minute != 0 {
            durationMinuteStr = "\(components.minute!)\(PropertyUtils.readLocalizedProperty("timepicker_minute"))"
        }
        //else {
        //    durationMinuteStr = "1" + PropertyUtils.readLocalizedProperty("timepicker_minute")
        //}
        if components.second != 0 {
            durationSecondStr = "\(components.second!)" + PropertyUtils.readLocalizedProperty("time_second")
        }
        
        return durationHourStr + durationMinuteStr + durationSecondStr
    }
    
    func computeDurationInt(sTime: String, eTime: String) -> Int {
        let dateFormatterX = DateFormatter()
        dateFormatterX.dateFormat = "yyyy/MM/dd-HH:mm:ss"
        dateFormatterX.timeZone = TimeZone(secondsFromGMT: 0)
        
        let sDate = dateFormatterX.date(from: sTime)
        let eDate = dateFormatterX.date(from: eTime)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
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
        
        print("totalSecond=\(totalSecond)")
        return totalSecond
    }
    
    func computeSwolf(second: Int, swimCount: Int) -> String {
        //13:39 yr_deng swim history 的單位就是趟
        //13:39 yr_deng 所以就時間+划手數
        print("computeSwolf() - second=\(second) swimCount=\(swimCount)!")
        return "\(second + swimCount) Swolf"
    }

    func computeDistanceDoubleValue(pool_size: Int) -> Double {
        // print("computeDistanceDoubleValue() :: poolsize=\(pool_size) lapNum=\(lapNum)!")
        print("computeDistanceDoubleValue() :: poolsize=\(pool_size) (0: 25m, 1: 50m, 2: 25yd, 3: 33 1/3m, 4: 33 1/3yd)!")
        // Swim Pool Size (0: 25m, 1: 50m, 2: 25yd, 3: 33 1/3m, 4: 33 1/3yd)
        
        // 全部轉公尺  加總 ＝>  公里   ＝>  英里
        var distance: Double = 0.0
        
        if pool_size == 0 {
            // 25m
            //distance = Double(25 * lapNum)
            distance = Double(25)
        } else if pool_size == 1 {
            // 50m
            //distance = Double(50 * lapNum)
            distance = Double(50)
        } else if pool_size == 2 {
            // 25yd
            // distance = Double(25 * lapNum)
            // distance = Double(25)
            distance = distance * 0.9144
        } else if pool_size == 3 {
            // 33 1/3m
            //distance = Double(33.33 * Double(lapNum))
            distance = Double(33.33)
        } else if pool_size == 4 {
            // 33 1/3yd
            //distance = Double(33.33 * Double(lapNum))
            //distance = Double(33.33)
            distance = distance * 0.9144
        }
        
        print("distance=\(distance)")
        return distance
    }
    
    func computeDistance(pool_size: Int, lapNum: Int) -> String {
        // Swim Pool Size (0: 25m, 1: 50m, 2: 25yd, 3: 33 1/3m, 4: 33 1/3yd)
        var poolUnit = ""
        
        if self.swimPoolSizeValue == "25yd" ||
            self.swimPoolSizeValue == "33 1/3yd" {
            poolUnit = PropertyUtils.readLocalizedProperty("swim_distance_yd_unit")
            //poolUnit = "yd"
        } else {
            poolUnit = PropertyUtils.readLocalizedProperty("swim_distance_m_unit")
            //poolUnit = "m"
        }
        
        var distance: Double = 0.0
        if pool_size == 0 {
            // 25m
            distance = Double(25)
        } else if pool_size == 1 {
            // 50m
            distance = Double(50)
        } else if pool_size == 2 {
            // 25yd
            distance = Double(25)
            //distance = distance * 0.9144
        } else if pool_size == 3 {
            // 33 1/3m
            distance = Double(33.33)
        } else if pool_size == 4 {
            // 33 1/3yd
            distance = Double(33.33)
            //distance = distance * 0.9144
        }
        
        return "\(distance) \(poolUnit)"
    }
    
    func computeCalIntValue(strokeState: Int, durationSecond: Double) -> Int {
        //self.timeLabel.text = timeString(time: TimeInterval(seconds))
        //self.durationTime = seconds / 60
        print("computeCalIntValue()!")
        if self.strokeTypeDict[strokeState] != nil {
            let calorie = CalcUtils.calcSwimCalorie(duration: durationSecond,
                                                    height: self.heightIntValue,
                                                    weight: self.weightIntValue,
                                                    gender: self.genderValue,
                                                    age: self.ageIntValue,
                                                    stroke: self.strokeTypeEnglishDict[strokeState]!)
            return calorie
        } else {
            let calorie = CalcUtils.calcSwimCalorie(duration: durationSecond,
                                                    height: self.heightIntValue,
                                                    weight: self.weightIntValue,
                                                    gender: self.genderValue,
                                                    age: self.ageIntValue,
                                                    stroke: self.strokeTypeEnglishDict[0]!)
            return calorie
        }
        
    }
    
    func computeCal(strokeState: Int, durationMinute: Double) -> String {
        //self.timeLabel.text = timeString(time: TimeInterval(seconds))
        //self.durationTime = seconds / 60
        print("computeCal()!")
        let calorie = CalcUtils.calcSwimCalorie(duration: durationMinute,
                                                height: self.heightIntValue,
                                                weight: self.weightIntValue,
                                                gender: self.genderValue,
                                                age: self.ageIntValue,
                                                stroke: self.strokeTypeEnglishDict[strokeState]!)
        return "\(calorie) " + PropertyUtils.readLocalizedProperty("calorie_k_unit")
    }
}

extension SwimHistoryVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwimCell", for: indexPath) as! SwimCell
        
        let swimData = self.currentDataArray[indexPath.row]
        
        // Others = 0,
        // FRONTCRAWL = 1
        // BACKSTROKE = 2
        // BREASTSTROKE = 3
        // BUTTERFLY = 4
        // HEADUPBREAST = 5
        cell.swimImageView.layer.cornerRadius = cell.swimImageView.frame.width * 0.5
        
        if swimData.stroke_type == 0 {
            cell.swimImageView.image = UIImage(named: "ic_swim_unknown_stroke")
            cell.swimTypeLabel.text = strokeTypeDict[0]
           
        } else if swimData.stroke_type == 3 || swimData.stroke_type == 5 {
            cell.swimImageView.image = UIImage(named: "ic_swim_breaststroke")
            cell.swimTypeLabel.text = strokeTypeDict[3]
            
        } else if swimData.stroke_type == 1 {
            cell.swimImageView.image = UIImage(named: "ic_swim_freestyle")
            cell.swimTypeLabel.text = strokeTypeDict[1]
            
        } else if swimData.stroke_type == 2 {
            cell.swimImageView.image = UIImage(named: "ic_swim_backstroke")
            cell.swimTypeLabel.text = strokeTypeDict[2]
            
        } else if swimData.stroke_type == 4 {
            cell.swimImageView.image = UIImage(named: "ic_swim_butterfly")
            cell.swimTypeLabel.text = strokeTypeDict[4]
            
        }
        let separatedStartTime = swimData.start_time.components(separatedBy: "-")
        let separatedEndTime = swimData.end_time.components(separatedBy: "-")
        cell.timeLabel.text = "\(separatedStartTime[1])~\(separatedEndTime[1])"
        cell.swimDurationLabel.text = computeDuration(sTime: swimData.start_time, eTime: swimData.end_time)
        cell.swolfLabel.text = computeSwolf(second: swimData.swimDuration, swimCount: swimData.stroke_count)
        
        cell.swimDistanceLabel.text = computeDistance(pool_size: swimData.pool_size, lapNum: swimData.lap_num)
        cell.swimCallLabel.text = computeCal(strokeState: swimData.stroke_type, durationMinute: Double(swimData.swimDuration)/60.0)
        cell.swimLapLabel.text = "\(swimData.lap_num) " + PropertyUtils.readLocalizedProperty("swim_lap")
        cell.swimSectionLabel.text = "\(swimData.section_num) " + PropertyUtils.readLocalizedProperty("swim_section")

        
        cell.timeLabel.font = font14
        cell.swimDurationLabel.font = font14
        cell.swolfLabel.font = font14
        cell.swimDistanceLabel.font = font14
        cell.swimCallLabel.font = font14
        cell.swimLapLabel.font = font14
        cell.swimSectionLabel.font = font14
        
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "SwimmingHistory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SwimSectionVC") as! SwimSectionVC
        
        vc.hidesBottomBarWhenPushed = true
        
        let tmp = self.currentDataArray[indexPath.row]
        vc.sectionDatas = self.currentSectionDataArray[tmp.section_num]!
        print("vc.sectionDatas=\(vc.sectionDatas)")
        vc.sectionNumber = tmp.section_num
        
        let separatedStartTime = tmp.start_time.components(separatedBy: "-")        
        vc.currentDate = separatedStartTime[0]
        
        self.navigationController!.pushViewController(vc, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

extension SwimHistoryVC: UITableViewDelegate {
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
extension SwimHistoryVC: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return ""
    }
}

extension SwimHistoryVC: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("\(Int(entry.x)), \(entry.y)")
        self.noteLabel.text = ""
        if entry.y > 0.0 {
            if let item = self.chartDict[Int(entry.x)] {
                let startTime = item.start_time
                let separatedStartTime = startTime.components(separatedBy: "-")
                let swimDuration = item.swimDuration
                
                self.noteLabel.text = "\(separatedStartTime[1]) \(swimDuration)\(PropertyUtils.readLocalizedProperty("time_second"))"
            }
        }
    }
}
