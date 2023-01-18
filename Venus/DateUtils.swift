//
//  DateUtils.swift
//  Venus
//
//  Created by Kenneth on 30/06/2017.
//  Copyright © 2017 ada. All rights reserved.
//

import Foundation

class DateUtils {

    class func convertMilliSecondsToDate(_ milliseconds: Double) -> Date {
        let utcDate = Date(timeIntervalSince1970: milliseconds / 1000)
        return utcDate
    }

    class func convertDateToMillisecondsString(_ date: Date) -> String {
        return String(format: "%.0f", floor(date.timeIntervalSince1970 * 1000))
    }

    class func stringFromCountDownTime(_ countDownTime: TimeInterval) -> String {
        let seconds: Int = Int(countDownTime.truncatingRemainder(dividingBy: 60))
        let minutes: Int = Int((countDownTime / 60).truncatingRemainder(dividingBy: 60))
        let hours: Int = Int(countDownTime / 60 / 60)
        return String(format: "%02d:%02d:%02d", arguments: [hours, minutes, seconds])
    }

    class func dateStrings(_ days: Int) -> [String] {

        var items = [String]()
        let oneDayTime: TimeInterval = 24 * 60 * 60
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for i in 0 ..< days {
            let tmp: TimeInterval = Double(i) * oneDayTime
            let dayToToday = Date().addingTimeInterval(-tmp)
            let dateStr = dateFormatter.string(from: dayToToday)
            items.append(dateStr)
        }

        return items
    }
    
    /**
     Date string of today
 
     - returns: Date string of today that format is "yyy-MM-dd"
     */
    class func today() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: Date())
    }
    
    class func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    class func timeStringArray(time:TimeInterval) -> [String] {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        let strHour = String(format:"%02i", hours)
        let strMin = String(format:"%02i", minutes)
        let strSec = String(format:"%02i", seconds)
        
        return [strHour, strMin, strSec]
    }
    
    class func timeIntArray(time:TimeInterval) -> [Int] {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return [hours, minutes, seconds]
    }
    
    class func getAgeString(birthdate: Date) -> String {
        
        let ageComponents = Calendar.current.dateComponents([.year, .month], from: birthdate, to: Date())
        
        var result = ""
        
        if let years = ageComponents.year {
            result = "\(years) year"
            
            if years > 1 {
                result = "\(result)s"
            }
            result = "\(result) and"
        }
        
        if let months = ageComponents.month {
            result = "\(result) \(String(months)) month"
            
            if months > 1 {
                result = "\(result)s"
            }
        }
        
        return "\(result) old"
    }
}
