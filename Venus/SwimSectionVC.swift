//
//  SwimSectionVC.swift
//  Venus
//
//  Created by Kenneth on 2017/Aug/13.
//  Copyright © 2017年 ADA. All rights reserved.
//

import UIKit
import Charts

class SwimSectionVC: UIViewController {
    var sectionNumber: Int = 0
    var sectionDatas = [swimDataStruct]()
    var currentDate: String = ""
    weak var axisFormatDelegate: IAxisValueFormatter?
    var avgPace = "00:00"
    var avgSwolf: Int = 0
    var totalTime = "00:00"
    //var plistManager = PlistManager()
    var swimPoolSizeValue: String = ""
    let font14 = UIFont.systemFontOfSizeByScreenWidth(375.0, fontSize: 14.0)
    let font15 = UIFont.systemFontOfSizeByScreenWidth(375.0, fontSize: 15.0)
    let font16 = UIFont.systemFontOfSizeByScreenWidth(375.0, fontSize: 16.0)
    let font17 = UIFont.systemFontOfSizeByScreenWidth(375.0, fontSize: 17.0)
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var paceUnitLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var swolfLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceUnitLabel: UILabel!
    @IBOutlet weak var calLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(sectionNumber)
        print(currentDate)
        print(sectionDatas)
        
        navigationItem.title = "\(PropertyUtils.readLocalizedProperty("swim_section"))\(sectionNumber) - \(currentDate)"
        let button: UIButton = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "ic_bluetooth_white"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        button.isHidden = true
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        //axisFormatDelegate = self
        self.barChartView.delegate = self
        
        self.noteLabel.text = ""
        
        self.processData()
#if false
        //10:12 yr_deng 中間的 pace = (33x2 + 56x2) / 2
        //10:12 yr_deng 中間的 Swolf 是 (swolf1+swolf2) / 2
        //10:16 yr_deng minute/距離
        //10:16 yr_deng 速度的意思
        //10:18 yr_deng 都是用 minute
        //10:19 yr_deng min/66yd
        //min/100m
        //min/50m
        //min/50yd
        //10:19 yr_deng min/66m
        //10:19 吳易達Kenneth 0.5 min / 66yd
        //10:19 yr_deng 對，30s 就是 00:30
        //10:20 yr_deng time format 是 XX:XX
        //10:20 yr_deng 分：秒
#endif
        //let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        //let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        //let unitsBought = [10.0, 14.0, 60.0, 13.0, 2.0, 1.0, 5.0, 1.0, 12.0, 14.0, 15.0, 14.0]
        
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<self.sectionDatas.count {
            // x : lap
            // y : pace, calorie
            let tmpPace = self.sectionDatas[i].swimDuration * 2
            let dataEntry = BarChartDataEntry(x: Double(i+1) ,
                                              yValues: [Double(tmpPace),
                                                        Double(self.sectionDatas[i].cal)])
            //print(tmpPace)
            //print(Double(self.sectionDatas[i].cal))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Swim Section")
        let chartData = BarChartData(dataSet: chartDataSet)
        let color1 = UIColor(red: 1.0/255.0, green: 250.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        let color2 = UIColor(red: 229.0/255.0, green: 58.0/255.0, blue: 229.0/255.0, alpha: 1.0)
        chartDataSet.colors = [color1, color2]
        chartDataSet.valueTextColor = UIColor.clear
        //barChartView.leftAxis.drawZeroLineEnabled = true
        barChartView.xAxis.labelTextColor = UIColor.white
        barChartView.xAxis.labelPosition = .bottom
        barChartView.leftAxis.labelTextColor = UIColor.white
        barChartView.rightAxis.labelTextColor = UIColor.white
        barChartView.xAxis.drawLabelsEnabled = true
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawAxisLineEnabled = true
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = true
        barChartView.legend.enabled = false
        barChartView.chartDescription?.enabled = false
        barChartView.chartDescription?.text = ""
        barChartView.drawValueAboveBarEnabled = false
        barChartView.noDataText = "You need to provide data for the chart."
        barChartView.data = chartData
        let xaxis = barChartView.xAxis
        xaxis.valueFormatter = axisFormatDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension SwimSectionVC {
    func checkPoolSizeUpdateUI(pool_size: Int) {
        // Swim Pool Size (0: 25m, 1: 50m, 2: 25yd, 3: 33 1/3m, 4: 33 1/3yd)
        if pool_size == 0 {
            // 25m
            self.distanceUnitLabel.text = PropertyUtils.readLocalizedProperty("swim_distance_m")
            self.paceUnitLabel.text = PropertyUtils.readLocalizedProperty("swim_avg_pace_25m")
        } else if pool_size == 1 {
            // 50m
            self.distanceUnitLabel.text = PropertyUtils.readLocalizedProperty("swim_distance_m")
            self.paceUnitLabel.text = PropertyUtils.readLocalizedProperty("swim_avg_pace_50m")
        } else if pool_size == 2 {
            // 25yd
            //distance = distance * 0.9144
            self.distanceUnitLabel.text = PropertyUtils.readLocalizedProperty("swim_distance_yd")
            self.paceUnitLabel.text = PropertyUtils.readLocalizedProperty("swim_avg_pace_25yd")
        } else if pool_size == 3 {
            // 33 1/3m
            self.distanceUnitLabel.text = PropertyUtils.readLocalizedProperty("swim_distance_m")
            self.paceUnitLabel.text = PropertyUtils.readLocalizedProperty("swim_avg_pace_33m")
        } else if pool_size == 4 {
            // 33 1/3yd
            //distance = distance * 0.9144
            self.distanceUnitLabel.text = PropertyUtils.readLocalizedProperty("swim_distance_yd")
            self.paceUnitLabel.text = PropertyUtils.readLocalizedProperty("swim_avg_pace_33yd")
        }
    }
    
    func computeDistance(pool_size: Int, lapNum: Int) -> Double {
        // Swim Pool Size (0: 25m, 1: 50m, 2: 25yd, 3: 33 1/3m, 4: 33 1/3yd)
        var distance: Double = 0.0
        if pool_size == 0 {
            // 25m
            distance = Double(25 * lapNum)
        } else if pool_size == 1 {
            // 50m
            distance = Double(50 * lapNum)
        } else if pool_size == 2 {
            // 25yd
            distance = Double(25 * lapNum)
            //distance = distance * 0.9144
        } else if pool_size == 3 {
            // 33 1/3m
            distance = Double(33.33 * Double(lapNum))
        } else if pool_size == 4 {
            // 33 1/3yd
            distance = Double(33.33 * Double(lapNum))
            //distance = distance * 0.9144
        }
        
        return distance
    }
    
    func processData() {
        var totalDuration: Int = 0
        var totalSwolf: Int = 0
        var totalDistance: Double = 0.0
        var totalCal: Int = 0
        for i in 0..<self.sectionDatas.count {
            let duration: Int = self.sectionDatas[i].swimDuration
            let strokeCount: Int = self.sectionDatas[i].stroke_count
            let tmpSwolf: Int = duration + strokeCount
            totalDuration = totalDuration + duration
            totalSwolf = totalSwolf + tmpSwolf
            
            let tmpDistance = self.computeDistance(pool_size: self.sectionDatas[i].pool_size, lapNum: 1)
            totalDistance = totalDistance + tmpDistance
            totalCal = totalCal + self.sectionDatas[i].cal
        }
        let avgDuration = (totalDuration * 2) / self.sectionDatas.count
        let avgDurationArray = DateUtils.timeIntArray(time: TimeInterval(avgDuration))
        self.avgPace = "\(avgDurationArray[1]):\(avgDurationArray[2])"
        //13:39 yr_deng swim history 的單位就是趟
        //13:39 yr_deng 所以就時間+划手數
        self.avgSwolf = totalSwolf / self.sectionDatas.count
    
        print("processData() :: totalDuration=\(totalDuration)")
        let totalDurationArray = DateUtils.timeStringArray(time: TimeInterval(totalDuration))
        print("processData() :: totalDurationArray=\(totalDurationArray)")
        self.timeLabel.text = "\(totalDurationArray[1]):\(totalDurationArray[2])"
        self.distanceLabel.text = "\(totalDistance)"
        self.calLabel.text = "\(totalCal)"
        self.paceLabel.text = self.avgPace
        self.swolfLabel.text = "\(self.avgSwolf)"
        
        self.checkPoolSizeUpdateUI(pool_size: self.sectionDatas[0].pool_size)
    }
}

// MARK: axisFormatDelegate
//extension SwimSectionVC: IAxisValueFormatter {
    //func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    //    return ""
    //}
//}

extension SwimSectionVC: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        /*
        0, 30.0
        1, 18.0
        2, 66.0
        3, 16.0
        4, 14.0
         lap:5 Pace:1:13 Calorie:6
        */
        print("\(Int(entry.x)), \(entry.y)")
        self.noteLabel.text = ""

        if entry.y > 0.0 {
            if Int(entry.x-1) < self.sectionDatas.count {
                let item = self.sectionDatas[Int(entry.x-1)]
                let duration = item.swimDuration
                let durationArray = DateUtils.timeStringArray(time: TimeInterval(duration))
                let paceStr = "\(durationArray[1]):\(durationArray[2])"
                
                self.noteLabel.text = "\(PropertyUtils.readLocalizedProperty("swim_lap")):\(Int(entry.x)) \(PropertyUtils.readLocalizedProperty("swim_pace")):\(paceStr) \(PropertyUtils.readLocalizedProperty("calorie")):\(item.cal)"
            }
        }
    }
}
