//
//  DateExtension.swift
//  Proto
//
//  Created by Kenneth on 08/12/2016.
//  Copyright © 2016 Ada. All rights reserved.
//

import Foundation

extension Date {
    
    func toString(format: String = "yyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
    // print(Date().dayNumberOfWeek()!) // 4
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    // print(Date().dayOfWeek()!) // Wednesday
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    var yester2day: Date {
        return Calendar.current.date(byAdding: .day, value: -2, to: self)!
    }
    var yester3day: Date {
        return Calendar.current.date(byAdding: .day, value: -3, to: self)!
    }
    var yester4day: Date {
        return Calendar.current.date(byAdding: .day, value: -4, to: self)!
    }
    var yester5day: Date {
        return Calendar.current.date(byAdding: .day, value: -5, to: self)!
    }
    var yester6day: Date {
        return Calendar.current.date(byAdding: .day, value: -6, to: self)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var year: Int {
        return Calendar.current.component(.year,  from: self)
    }
    var day: Int {
        return Calendar.current.component(.day,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
    
    /*
    Date().yesterday   // "May 15, 2017, 4:27 PM"
    Date()             // "May 16, 2017, 4:27 PM"
    Date().tomorrow    // "May 17, 2017, 4:27 PM"
 
    Date().tomorrow.noon // "May 17, 2017, 12:00 PM"
    Date().yesterday.month   // 5
    Date().isLastDayOfMonth  // false
    */
    
    func add(minutes: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self)!
    }
    
    //  Date().add(minutes: 10)  //  "Jun 14, 2016, 5:31 PM"
    
    func dateAt(day: Int, hours: Int, minutes: Int) -> Date
    {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        //get the month/day/year componentsfor today's date.
        
        
        var date_components = calendar.components(
            [NSCalendar.Unit.year,
             NSCalendar.Unit.month,
             NSCalendar.Unit.day],
            from: self)
        
        //Create an NSDate for the specified time today.
        date_components.day = day
        date_components.hour = hours
        date_components.minute = minutes
        date_components.second = 0
        
        let newDate = calendar.date(from: date_components)!
        return newDate
    }
}
