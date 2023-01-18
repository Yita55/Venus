//
//  TimeViewController.swift
//  Wake Me Up
//
//  Created by Andrew Petrosky on 4/9/17.
//  Copyright © 2017 edu.upenn.seas.cis195. All rights reserved.
//

import UIKit
import CoreData

class TimeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var timePicker: UIDatePicker!
    // var detailsController : DetailTableViewController!
    @IBOutlet weak var repeatTable: UITableView!
    var alarmText: String = ""
    var rootController : AlarmsTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timePicker.backgroundColor = UIColor.black
        timePicker.setValue(UIColor.green, forKeyPath: "textColor")
        timePicker.setValue(1.0, forKeyPath: "alpha")
        
        repeatTable.dataSource = self
        repeatTable.delegate = self
        
        repeatTable.tableFooterView = UIView(frame: CGRect.zero)
        //let timeArray = detailsController.alarmTime.text?.components(separatedBy: ", ")
        if alarmText != "" {
            let timeArray = alarmText.components(separatedBy: ", ")
            
            if timeArray.count == 2 {
                let repeats = timeArray[1]
                repeatTable.reloadData()
                if repeats.contains("M") {
                    let cell = self.repeatTable.cellForRow(at: IndexPath(row: 0, section: 0))
                    cell?.accessoryType = .checkmark
                }
                if repeats.contains("TU") {
                    let cell = self.repeatTable.cellForRow(at: IndexPath(row: 1, section: 0))
                    cell?.accessoryType = .checkmark
                }
                if repeats.contains("W") {
                    let cell = self.repeatTable.cellForRow(at: IndexPath(row: 2, section: 0))
                    cell?.accessoryType = .checkmark
                }
                if repeats.contains("TH") {
                    let cell = self.repeatTable.cellForRow(at: IndexPath(row: 3, section: 0))
                    cell?.accessoryType = .checkmark
                }
                if repeats.contains("F") {
                    let cell = self.repeatTable.cellForRow(at: IndexPath(row: 4, section: 0))
                    cell?.accessoryType = .checkmark
                }
                if repeats.contains("SA") {
                    let cell = self.repeatTable.cellForRow(at: IndexPath(row: 5, section: 0))
                    cell?.accessoryType = .checkmark
                }
                if repeats.contains("SU") {
                    let cell = self.repeatTable.cellForRow(at: IndexPath(row: 6, section: 0))
                    cell?.accessoryType = .checkmark
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpAlarm(alarm : NSManagedObject, time: String, repeats: String) -> NSManagedObject {
        alarm.setValue("alarmName", forKeyPath: "name")
        alarm.setValue("", forKeyPath: "contactNumber")
        alarm.setValue("None", forKeyPath: "textContact")
        alarm.setValue("sound 1", forKeyPath: "sound")
        alarm.setValue("alarm text", forKeyPath: "textAfter")
        alarm.setValue(time, forKeyPath: "time")
        alarm.setValue(repeats, forKeyPath: "timeRepeat")
        alarm.setValue(true, forKeyPath: "snooze")
        alarm.setValue(true, forKeyPath: "enabled")
        return alarm
    }
    
    @IBAction func doneSelectingTime(_ sender: Any) {
        /*
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        let time = timeFormatter.string(from: timePicker.date)
        */
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: timePicker.date)
        let repeats = getRepeats()
        // detailsController.alarmTime.text = time + repeats
        // write to db
        var alarm : NSManagedObject
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if #available(iOS 10.0, *) {
                let managedContext = appDelegate.persistentContainer.viewContext
                
                alarm = (self.rootController.alarms?[self.rootController.curAlarm])!
                #if false
                self.rootController.alarms?.remove(at: self.rootController.curAlarm)
                //AlarmNotifications.disableAlarmNotificationsFor(alarm: alarm)
                managedContext.delete(alarm)
                
                let entity = NSEntityDescription.entity(forEntityName: "Alarm", in: managedContext)!
                alarm = NSManagedObject(entity: entity, insertInto: managedContext)
                alarm = setUpAlarm(alarm: alarm, time: time, repeats: repeats)
                try? managedContext.save()
                self.rootController.alarms?.append(alarm)
                self.rootController.tableView.reloadData()
                #endif
                
                alarm.setValue(time, forKey: "time")
                alarm.setValue(repeats, forKey: "timeRepeat")
                try? managedContext.save()
                
                self.rootController.tableView.reloadData()
                
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            return
        }
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func getRepeats() -> String {
        var repeats = ""
        for r in 0...6 {
            let cell = self.repeatTable.cellForRow(at: IndexPath(row: r, section: 0))
            if cell?.accessoryType == .checkmark {
                if r == 0 {
                    repeats = repeats + " M"
                } else if r == 1 {
                    repeats = repeats + " TU"
                } else if r == 2 {
                    repeats = repeats + " W"
                } else if r == 3 {
                    repeats = repeats + " TH"
                } else if r == 4 {
                    repeats = repeats + " F"
                } else if r == 5 {
                    repeats = repeats + " SA"
                } else {
                    repeats = repeats + " SU"
                }
            }
        }
        /*
        if repeats != "" {
            repeats = ", " + repeats
        }
        */
        return repeats
    }

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repeatCell", for: indexPath)
        let r = indexPath.row
        if r == 0 {
            cell.textLabel?.text = "Monday"
        } else if r == 1 {
            cell.textLabel?.text = "Tuesday"
        } else if r == 2 {
            cell.textLabel?.text = "Wednesday"
        } else if r == 3 {
            cell.textLabel?.text = "Thursday"
        } else if r == 4 {
            cell.textLabel?.text = "Friday"
        } else if r == 5 {
            cell.textLabel?.text = "Saturday"
        } else {
            cell.textLabel?.text = "Sunday"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }
    }
}
