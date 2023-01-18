//
//  AlarmsTableViewController.swift
//  Wake Me Up
//
//  Created by Andrew Petrosky on 4/8/17.
//  Copyright © 2017 edu.upenn.seas.cis195. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth
import EZAlertController
import Bitter

class AlarmsTableViewController: UITableViewController {
    
    var newAlarm = true
    var curAlarm = 0;
    var alarms : [NSManagedObject]?
    var btDataModel = BTDataModel.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAlarms()
    }
    
    func setUpAlarm(alarm : NSManagedObject, alarmNum : Int) -> NSManagedObject {
        let alarmName = "Alarm" + "\(alarmNum)"
        
        alarm.setValue(alarmName, forKeyPath: "name")
        alarm.setValue("", forKeyPath: "contactNumber")
        alarm.setValue("None", forKeyPath: "textContact")
        alarm.setValue("sound 1", forKeyPath: "sound")
        alarm.setValue("alarm text", forKeyPath: "textAfter")
        alarm.setValue("8:00", forKeyPath: "time")
        alarm.setValue(" M TU W TH F", forKeyPath: "timeRepeat")
        alarm.setValue(true, forKeyPath: "snooze")
        alarm.setValue(true, forKeyPath: "enabled")
        return alarm
    }
    
    func createFourAlarms() {
        for i in 0 ..< 4 {
            var alarm : NSManagedObject
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                if #available(iOS 10.0, *) {
                    let managedContext = appDelegate.persistentContainer.viewContext
                    
                    let entity = NSEntityDescription.entity(forEntityName: "Alarm", in: managedContext)!
                    
                    alarm = NSManagedObject(entity: entity, insertInto: managedContext)
                    alarm = setUpAlarm(alarm: alarm, alarmNum: i+1)
                    try? managedContext.save()
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        loadAlarms()
    }
    
    func loadAlarms() {
        alarms = []
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if #available(iOS 10.0, *) {
                let managedContext = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Alarm")
                do {
                    alarms = try managedContext.fetch(fetchRequest)
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            return
        }
        
        if (alarms?.count)! > 0 {
            self.tableView.reloadData()
        } else {
            createFourAlarms()
        }
    }
    
    @IBAction func toggleAlarm(_ sender: Any) {
        if let swit = sender as? UISwitch {
            if let superview = swit.superview {
                if let cell = superview.superview as? AlarmTableViewCell {
                    let indexPath = self.tableView.indexPath(for: cell)
                    let alarm = alarms?[(indexPath?.row)!]
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        alarm?.setValue(swit.isOn, forKey: "enabled")
                        appDelegate.saveContext()
                        if swit.isOn {
                            /*
                            AlarmNotifications.enableAlarmNotificationsFor(alarm: alarm!)
                            */
                        } else {
                            /*
                            AlarmNotifications.disableAlarmNotificationsFor(alarm: alarm!)
                            */
                        }
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @IBAction func addAlarm(_ sender: Any) {
        /*
        if (alarms?.count)! < 4 {
            newAlarm = true
            self.performSegue(withIdentifier: "editAlarmSegue", sender: self)
        } else {
            print("最多四組")
            return
        }
        */
        
    }
    
    @IBAction func saveToDevice(_ sender: Any) {
        print("start to write Alarm Info to Device!")
        if btDataModel.btConnectedPeripheral == nil {
            EZAlertController.alert(PropertyUtils.readLocalizedProperty("Warning"), message: PropertyUtils.readLocalizedProperty("no_device_bonded"), acceptMessage: PropertyUtils.readLocalizedProperty("ok")) { () -> () in
                print("cliked OK")
            }
        } else {
            var writeParam: [UInt8] = [0x55, 0xF9, 0x04]
            
            for i in 0 ..< Int((alarms?.count)!) {
                let alarm = alarms?[i]
                let alarmEnable = (alarm?.value(forKeyPath: "enabled") as? Bool)!
                let repeats = (alarm?.value(forKeyPath: "timeRepeat") as? String)!
                let time = (alarm?.value(forKeyPath: "time") as? String)!
                
                print("time=\(String(describing: time)) repeats=\(String(describing: repeats))")
                print(alarmEnable)
                //time=Optional("07:48") repeats=Optional(" M TH F")
                //time=Optional("07:13") repeats=Optional(" M W TH F")
                //time=Optional("05:16") repeats=Optional(" M TH F")
                //time=Optional("23:17") repeats=Optional(" M F")

                let separatedTimes = time.components(separatedBy: ":")
                let hour = Int(separatedTimes[0])!
                let minute = Int(separatedTimes[1])!
                
                // https://github.com/uraimo/Bitter
                var alarmParameter: UInt8 = 0x00
                
                if alarmEnable == true {
                    alarmParameter = alarmParameter.setb7(1)
                } else {
                    alarmParameter = alarmParameter.setb7(0)
                }
                
                //          bits[1] Sunday
                //          bits[2] Monday
                //          bits[3] Tuesday
                //          bits[4] Wednesday
                //          bits[5] Thursday
                //          bits[6] Friday
                //          bits[7] Saturday
                
                if repeats.range(of:"SU") != nil {
                    print("SU exists")
                    alarmParameter = alarmParameter.setb6(1)
                }
                
                if repeats.range(of:"M") != nil {
                    print("M exists")
                    alarmParameter = alarmParameter.setb5(1)
                }
                
                if repeats.range(of:"TU") != nil {
                    print("TU exists")
                    alarmParameter = alarmParameter.setb4(1)
                }
                
                if repeats.range(of:"W") != nil {
                    print("W exists")
                    alarmParameter = alarmParameter.setb3(1)
                }
                
                if repeats.range(of:"TH") != nil {
                    print("TH exists")
                    alarmParameter = alarmParameter.setb2(1)
                }
                
                if repeats.range(of:"F") != nil {
                    print("F exists")
                    alarmParameter = alarmParameter.setb1(1)
                }
                
                if repeats.range(of:"SA") != nil {
                    print("SA exists")
                    alarmParameter = alarmParameter.setb0(1)
                }
                //0x0111 1101  =  125
                //0x1011 1110  =  190
                //BE
                
                let alarmSetting: [UInt8] = [UInt8(i+1),
                                             UInt8(hour),
                                             UInt8(minute),
                                             alarmParameter]
                
                writeParam = writeParam + alarmSetting
                
                // data format 20 bytes for CC defined alarm data
                // [55]:[F9]:[04]:[01]:[06]:[00]:[FF]:
                //                [02]:[07]:[00]:[FF]:
                //                [03]:[08]:[00]:[FF]:
                //                [04]:[09]:[00]:[FF]:00
                // bytes[0]: Send header 0x55
                // bytes[1]: Alarm data flag 0xF9
                // bytes[2]: Number of alarms
                // bytes[3~6]: Index 1 alarm
                //      bytes[3]: Index
                //      bytes[4]: Hour
                //      bytes[5]: Minute
                //      bytes[6]: Alarm parameter
                //          bits[0] Enable/Disable
                //          bits[1] Sunday
                //          bits[2] Monday
                //          bits[3] Tuesday
                //          bits[4] Wednesday
                //          bits[5] Thursday
                //          bits[6] Friday
                //          bits[7] Saturday
                // bytes[7~10]: Index 2 alarm
                // bytes[11~14]: Index 3 alarm
                // bytes[15~18]: Index 4 alarm
                // bytes[19]: Reserved
            }
            
            let byte19: [UInt8] = [0x00]
            
            writeParam = writeParam + byte19
            
            print(writeParam)
            
            btDataModel.writeToPeripheral(writeParam)
            
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (alarms?.count)!
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath) as! AlarmTableViewCell
        let alarm = alarms?[indexPath.row]
        let repeats = (alarm?.value(forKeyPath: "timeRepeat") as? String)
        if let r = repeats {
            if r == "" {
                //cell.alarmName?.text = (alarm?.value(forKeyPath: "name") as? String)!
                cell.alarmName?.text = ""
            } else {
                //cell.alarmName?.text = (alarm?.value(forKeyPath: "name") as? String)! + ", " + r
                cell.alarmName?.text = r
            }
        } else {
            //cell.alarmName?.text = (alarm?.value(forKeyPath: "name") as? String)!
            cell.alarmName?.text = ""
        }
        //cell.alarmName.backgroundColor = UIColor.green
        cell.alarmContact?.text = alarm?.value(forKeyPath: "textContact") as? String
        cell.alarmTime?.text = alarm?.value(forKeyPath: "time") as? String
        cell.alarmEnable.isOn = (alarm?.value(forKeyPath: "enabled") as? Bool)!
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newAlarm = false
        curAlarm = indexPath.row
        
        let storyboard = UIStoryboard(name: "Alarm", bundle: nil)
        let dest = storyboard.instantiateViewController(withIdentifier: "TimeViewController") as! TimeViewController
        
        let alarm = alarms?[curAlarm]
        var repText = ""
        var timeText = ""
        
        let repeats = (alarm?.value(forKeyPath: "timeRepeat") as? String)
        print("@didselectRow: curAlarm=\(curAlarm) repeats=\(String(describing: repeats))!")
        if let r = repeats {
            if r == "" {
                //cell.alarmName?.text = (alarm?.value(forKeyPath: "name") as? String)!
                repText = ""
            } else {
                //cell.alarmName?.text = (alarm?.value(forKeyPath: "name") as? String)! + ", " + r
                repText = r
            }
        } else {
            //cell.alarmName?.text = (alarm?.value(forKeyPath: "name") as? String)!
            repText = ""
        }
        
        timeText = (alarm?.value(forKeyPath: "time") as? String)!
        dest.alarmText = timeText + ", " + repText
        dest.rootController = self
        navigationController?.pushViewController(dest, animated: true)
        //self.performSegue(withIdentifier: "selectTimeSegue", sender: self)
        //self.performSegue(withIdentifier: "editAlarmSegue", sender: self)
    }

    /*
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alarm = alarms?[indexPath.row]
            alarms?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let managedContext = appDelegate.persistentContainer.viewContext
                managedContext.delete(alarm!)
                try? managedContext.save()
                AlarmNotifications.disableAlarmNotificationsFor(alarm: alarm!)
            }
        }
    }
    */
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
        if segue.identifier == "editAlarmSegue" {
            let dest = segue.destination as! NewAlarmViewController
            let backItem = UIBarButtonItem()
            backItem.title = "Cancel"
            navigationItem.backBarButtonItem = backItem
            dest.rootController = self
            if newAlarm {
                dest.navigationItem.title = "Add New Alarm"
            } else {
                dest.navigationItem.title = "Edit Alarm"
            }
        } else
        */
        if segue.identifier == "selectTimeSegue" {
#if false
            let dest = segue.destination as! TimeViewController
            let alarm = alarms?[curAlarm]
            var repText = ""
            var timeText = ""
            
            let repeats = (alarm?.value(forKeyPath: "timeRepeat") as? String)
            print("@selectTimeSegue: curAlarm=\(curAlarm) repeats=\(String(describing: repeats))!")
            if let r = repeats {
                if r == "" {
                    //cell.alarmName?.text = (alarm?.value(forKeyPath: "name") as? String)!
                    repText = ""
                } else {
                    //cell.alarmName?.text = (alarm?.value(forKeyPath: "name") as? String)! + ", " + r
                    repText = r
                }
            } else {
                //cell.alarmName?.text = (alarm?.value(forKeyPath: "name") as? String)!
                repText = ""
            }
            
            timeText = (alarm?.value(forKeyPath: "time") as? String)!
            dest.alarmText = timeText + ", " + repText
            dest.rootController = self
#endif
            //dest.detailsController = self.embeddedDetailViewController
        } else {
            let backItem = UIBarButtonItem()
            backItem.title = "My Alarms"
            navigationItem.backBarButtonItem = backItem
        }
    }
}
