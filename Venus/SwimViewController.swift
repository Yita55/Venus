//
//  SwimViewController.swift
//  Venus
//
//  Created by Kenneth on 20/06/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import UIKit
import CoreBluetooth
import KDCircularProgress
import SwiftProgressHUD
import EZAlertController

class SwimViewController: UIViewController {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var swolfLabel: UILabel!
    @IBOutlet weak var swimLabel: UILabel!
    @IBOutlet weak var circleProgress: KDCircularProgress!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var showSwimTypeLabel: UILabel!
    @IBOutlet weak var showSwimTypeImage: UIImageView!
    @IBOutlet weak var circleView1: UIView!
    @IBOutlet weak var circleView2: UIView!
    @IBOutlet weak var circleView3: UIView!
    @IBOutlet weak var distanceTextLabel: UILabel!
    @IBOutlet weak var timeText: UILabel!
    @IBOutlet weak var strokeCountTitleLabel: UILabel!
    @IBOutlet weak var kcalUnitLabel: UILabel!
    @IBOutlet weak var modeImageView: UIImageView!

    @IBAction func swimModeSwitch(_ sender: UIBarButtonItem) {
        if btDataModel.btConnectedPeripheral == nil {
            EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"), message: PropertyUtils.readLocalizedProperty("no_device_bonded"), acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
                print("cliked OK")
                return
            }
        } else {
            if btDataModel.currentMode == 2 {
                // step mode
                //btDataModel.currentMode = 1
                btDataModel.disableSwimMode()
            } else {
                //btDataModel.currentMode = 2
                btDataModel.enableSwimMode()
                resetUIandData()
            }
        }
    }
    
    @IBAction func goToSwimHistory(_ sender: UIButton) {
        print("goToSwimHistory!")
        let storyboard = UIStoryboard(name: "SwimmingHistory", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SwimHistoryVC") as! SwimHistoryVC
        
        vc.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(vc, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // call BTDataModel.sharedInstance will start scan device
    var btDataModel = BTDataModel.sharedInstance
    // var updateTimer: Timer?
    var currentAngle: Double = 0
    var plistManager = PlistManager()
    var globalTimestamp: TimeInterval?
    var heightIntValue: Int = 0
    var weightIntValue: Int = 0
    var ageIntValue: Int = 0
    var genderValue: String = ""
    var swimPoolSizeValue: String = ""
    var birthdayValue: String = ""
    
    let font14 = UIFont.systemFontOfSizeByScreenWidth(375.0, fontSize: 14.0)
    let font15 = UIFont.systemFontOfSizeByScreenWidth(375.0, fontSize: 15.0)
    let font16 = UIFont.systemFontOfSizeByScreenWidth(375.0, fontSize: 16.0)
    let font17 = UIFont.systemFontOfSizeByScreenWidth(375.0, fontSize: 17.0)
    
    var flagForProgress = 0
    var flagForTimer = 0
    var timer = Timer()
    var seconds: Int = 0
    var durationTime: Double = 0.0  // total time => minute
    var secondsOfOneLap: Int = 0  //  one lap time
    var startSecondOfOneLap: Int = 0  // one lap start time
    var endSecondOfOneLap: Int = 0 // one lap end time
    var lastLapNum: Int = 0  //  last Lap Num
    var currentLapNum: Int = 0  //  current Lap Num
    var swimCountNum: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(SwimViewController.updateUI(_:)), name: NSNotification.Name(rawValue: kNotifySwimData), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SwimViewController.disConnectedBluetoothDevice(_:)), name: NSNotification.Name(rawValue: kDeviceDisConnected), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SwimViewController.updateModeImageToStepMode), name: NSNotification.Name(rawValue: kNotifyStepMode), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SwimViewController.updateModeImageToSwimMode), name: NSNotification.Name(rawValue: kNotifySwimMode), object: nil)
        
        self.timeText.text = PropertyUtils.readLocalizedProperty("time")
        
        self.strokeCountTitleLabel.text = PropertyUtils.readLocalizedProperty("swim_stroke_count")
        
        self.kcalUnitLabel.text = PropertyUtils.readLocalizedProperty("calorie_k_unit")
        
        flagForProgress = 0
        flagForTimer = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showSwimTypeImage.isHidden = true
        //self.runTimer()
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
                if self.swimPoolSizeValue == "25yd" ||
                    self.swimPoolSizeValue == "33 1/3yd" {
                    self.distanceTextLabel.text = PropertyUtils.readLocalizedProperty("swim_distance_yd")
                } else {
                    self.distanceTextLabel.text = PropertyUtils.readLocalizedProperty("swim_distance_m")
                }
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
                if self.swimPoolSizeValue == "25yd" ||
                    self.swimPoolSizeValue == "33 1/3yd" {
                    self.distanceTextLabel.text = PropertyUtils.readLocalizedProperty("swim_distance_yd")
                } else {
                    self.distanceTextLabel.text = PropertyUtils.readLocalizedProperty("swim_distance_m")
                }
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
                if self.swimPoolSizeValue == "25yd" ||
                    self.swimPoolSizeValue == "33 1/3yd" {
                    self.distanceTextLabel.text = PropertyUtils.readLocalizedProperty("swim_distance_yd")
                } else {
                    self.distanceTextLabel.text = PropertyUtils.readLocalizedProperty("swim_distance_m")
                }
            }
        }
        if btDataModel.btAvailable == true {
            if btDataModel.btConnectedPeripheral != nil {
                // no neet to call ???
                // Note: set StepHeartRateNotift also return swim data!
                // btDataModel.startStepHeartRateNotify()
            }
        }
        
        // don't reset timer
#if false
        flagForProgress = 0
        flagForTimer = 0
#endif
        circleProgress.startAngle = 270
        circleProgress.progressThickness = 0.2
        circleProgress.trackThickness = 0.2
        circleProgress.clockwise = true
        circleProgress.gradientRotateSpeed = 2
        circleProgress.roundedCorners = false
        circleProgress.glowMode = .forward
        circleProgress.glowAmount = 0.9
        circleProgress.set(colors: UIColor(red: 5/255, green: 170/255, blue: 251/255, alpha: 1))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.globalTimestamp = nil
#if false
        DispatchQueue.main.async(execute: {
            self.timer.invalidate()
            self.flagForProgress = 0
            self.flagForTimer = 0
        })
#endif
        
        // ??? check if reset ???
        /*
        seconds = 0
        durationTime = 0
        secondsOfOneLap = 0
        startSecondOfOneLap = 0
        endSecondOfOneLap = 0
        lastLapNum = 0
        currentLapNum = 0
        swimCountNum = 0
        timeLabel.text = timeString(time: TimeInterval(seconds))
        */
    }
    
    func timeString(time:TimeInterval) -> String {
        //let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        //return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func checkLapNumberChanged(currentSecond: Int) -> Bool {
        print("checkLapNumberChanged! - before=\(lastLapNum) now=\(currentLapNum) currSecond=\(currentSecond)")
        // 1 > 0
        if currentLapNum > lastLapNum {
            lastLapNum = currentLapNum   //  update lap number
            /*
            if self.currentLapNum == 0 {
                self.startSecondOfOneLap = 0
            } else {
                self.startSecondOfOneLap = currentSecond
            }
            */
            return true
        } else {
            return false
        }
    }
    
    func updateTimer() {
        //if seconds < 1 {
        if seconds > 86400 {
            timer.invalidate()
            flagForProgress = 0
            flagForTimer = 0
            seconds = 0
            lastLapNum = 0
            //Send alert to indicate time's up.
        } else {
            if self.checkLapNumberChanged(currentSecond: seconds) {
                self.endSecondOfOneLap = seconds
                self.secondsOfOneLap = self.endSecondOfOneLap - self.startSecondOfOneLap
                
                if self.swimCountNum > 0 {
                    self.swolfLabel.text = "\(self.secondsOfOneLap + self.swimCountNum)"
                }
                
                self.startSecondOfOneLap = self.endSecondOfOneLap
            }
            seconds += 1
            self.timeLabel.text = timeString(time: TimeInterval(seconds))
            self.durationTime = Double(seconds) / 60.0
            // timerLabel.text = String(seconds)
            //            labelButton.setTitle(timeString(time: TimeInterval(seconds)), for: UIControlState.normal)
        }
    }
    
    func runTimer() {
        self.timeLabel.text = "00:00"
        self.seconds = 0
        self.lastLapNum = 0
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: (#selector(SwimViewController.updateTimer)),
                                     userInfo: nil,
                                     repeats: true)
        //isTimerRunning = true
    }
    
    func updateUI(_ notification: Notification) {
        if self.flagForProgress == 0 {
            SwiftProgressHUD.showOnlyText( PropertyUtils.readLocalizedProperty("swim_mode_starting") )
            
            /// 模拟 1s后 加载完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                SwiftProgressHUD.hideAllHUD()
            }
            
            self.flagForProgress = 1
        }
        
        let strokeType = (notification as NSNotification).userInfo?["StrokeType"] as! String
        let swimCount = (notification as NSNotification).userInfo?["SwimCount32UInt"] as! UInt32
        let swimLap = (notification as NSNotification).userInfo?["SwimLap32UInt"] as! UInt32
        let swimStrokeTimeLap = (notification as NSNotification).userInfo?["SwimStrokeTimeLap32UInt"] as! UInt32
        
        self.swimCountNum = Int(swimCount)
        self.currentLapNum = Int(swimLap)
        let swimStrokeTimeLapNum = Int(swimStrokeTimeLap)
        
        print("SwimViewController - updateUI :: strokeType=\(strokeType) swimCountNum=\(swimCountNum) swimLapNum=\(self.currentLapNum) swimStrokeTimeLapNum=\(swimStrokeTimeLapNum)")
        
        DispatchQueue.main.async(execute: {
            if self.flagForTimer == 0 &&
                self.swimCountNum > 0 &&
                self.btDataModel.currentMode == 2 {
                self.runTimer()
                self.flagForTimer = 1
            }
            if self.swimCountNum > 0 &&
                self.btDataModel.currentMode == 2 {
                self.currentAngle = Double((self.swimCountNum * 360 ) / 100)
                
                if self.currentAngle > 360 {
                    // ???
                    self.currentAngle = 0
                }
                print("Swim currentAngle=\(self.currentAngle)")
                self.circleProgress.angle = self.currentAngle
                
                self.showSwimTypeLabel.text = strokeType
                self.showSwimTypeImage.isHidden = false
                
                if strokeType == "BACKSTROKE" {
                    self.showSwimTypeImage.image = UIImage(named: "ic_swim_backstroke")
                } else if strokeType == "BREASTSTROKE" {
                    self.showSwimTypeImage.image = UIImage(named: "ic_swim_breaststroke")
                } else if strokeType == "BUTTERFLY" {
                    self.showSwimTypeImage.image = UIImage(named: "ic_swim_butterfly")
                } else if strokeType == "FRONTCRAWL" || strokeType == "HEADUPBREAST" {
                    self.showSwimTypeImage.image = UIImage(named: "ic_swim_freestyle")
                } else {
                    self.showSwimTypeImage.image = UIImage(named: "ic_swim_unknown_stroke")
                }
                
                self.swimLabel.text = "\(self.swimCountNum)"
                
                let size = self.swimPoolSizeValue
                var distance: Double = 0.0
                if size == "25m" {
                    //distance = Double(25 * (swimLapNum + 1))
                    distance = Double(25 * self.currentLapNum)
                } else if size == "50m" {
                    distance = Double(50 * self.currentLapNum)
                } else if size == "25yd" {
                    distance = Double(25 * self.currentLapNum)
                    //distance = distance * 0.9144
                } else if size == "33 1/3m" {
                    distance = Double(33.33 * Double(self.currentLapNum))
                } else if size == "33 1/3yd" {
                    //distance = Double(33.33 * Double(swimLapNum + 1))
                    distance = Double(33.33 * Double(self.currentLapNum))
                    //distance = distance * 0.9144
                }
                self.distanceLabel.text = "\(distance)"
                
                let calorie = CalcUtils.calcSwimCalorie(duration: self.durationTime,
                                                        height: self.heightIntValue,
                                                        weight: self.weightIntValue,
                                                        gender: self.genderValue,
                                                        age: self.ageIntValue,
                                                        stroke: strokeType)
                self.kcalLabel.text = "\(calorie)"
            }
        })
    }
    
    func resetUIandData() {
        seconds = 0
        durationTime = 0.0
        secondsOfOneLap = 0
        startSecondOfOneLap = 0
        endSecondOfOneLap = 0
        lastLapNum = 0
        currentLapNum = 0
        swimCountNum = 0
        
        DispatchQueue.main.async(execute: {
            self.timeLabel.text = "00:00"
            self.distanceLabel.text = "0.0"
            self.swolfLabel.text = "-"
            self.swimLabel.text = "0"
            self.kcalLabel.text = "0"
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SwimViewController {
    func disConnectedBluetoothDevice(_ notification: Notification) {
        guard let peripheralName = (notification as NSNotification).userInfo?["PeripheralName"] else {
            return
        }
        print("SwimViewController - disConnectedBluetoothDevice :: peripheralName=\(peripheralName)")
        
        // update mode Image
        DispatchQueue.main.async(execute: {
            self.modeImageView.isHidden = true
            self.showSwimTypeImage.isHidden = true
            self.timer.invalidate()
            self.flagForProgress = 0
            self.flagForTimer = 0
        })
    }
    
    func updateModeImageToStepMode() {
        print("SwimViewController - updateModeImageToStepMode")
        
        // update mode Image
        DispatchQueue.main.async(execute: {
            self.modeImageView.isHidden = false
            self.modeImageView.image = UIImage(named: "ic_walk_mode")
            self.showSwimTypeImage.isHidden = true
            self.timer.invalidate()
            self.flagForProgress = 0
            self.flagForTimer = 0
        })
    }
    
    func updateModeImageToSwimMode() {
        print("SwimViewController - updateModeImageToSwimMode")
        
        // update mode Image
        DispatchQueue.main.async(execute: {
            self.modeImageView.isHidden = false
            self.modeImageView.image = UIImage(named: "ic_swim_mode")
        })
    }
}
