//
//  Int+Extension.swift
//  MyTaxPal
//
//  Created by iOS Developer on 5/21/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import Foundation

// Weekday constants
let kWeekdaySunday = 1
let kWeekdayMonday = 2
let kWeekdayTuesday = 3
let kWeekdayWednesday = 4
let kWeekdayThursday = 5
let kWeekdayFriday = 6
let kWeekdaySaturday = 7

extension Date {
    
    var year: Int {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year], from: self as Date)
        return components.year ?? 0
    }
    
    var month: Int {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.month], from: self as Date)
        return components.month ?? 0
    }
    
    var day: Int {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.day], from: self as Date)
        return components.day ?? 0
    }
    
    var weekOfYear: Int {
        var calendar = NSCalendar.current
        calendar.firstWeekday = 1
        let components = calendar.dateComponents([.weekOfYear], from: self as Date)
        return components.weekOfYear ?? 0
    }
    
    var weekday: Int {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.weekday], from: self as Date)
        return components.weekday ?? 0
    }
    
    var firstDayOfTheYear: Date {
        let year = self.year
        let newDate = Date.getDateFrom(year: year, month: 1, day: 1)
        return newDate
    }
    
    func numberOfDaysUntilDateTime(toDateTime: Date, inTimeZone timeZone: TimeZone? = nil) -> Int {
        var calendar = Calendar.current
        if let timeZone = timeZone {
            calendar.timeZone = timeZone
        }
        
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: toDateTime)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day!
    }
    
    static func getFirstWeekDateInYear(year: Int) -> Date {
        let date = getDateFrom(year: year, month: 1, day: 1)
        let weekday = date.weekday
        if weekday == kWeekdayMonday {
            return date
        }
        else if weekday == kWeekdaySunday {
            let newDate = getDateFrom(year: year, month: 1, day: 2)
            return newDate
        }
        else {
            let diff = kWeekdayMonday + 7 - weekday
            let newDate = getDateFrom(year: year, month: 1, day: diff+1)
            return newDate
        }
    }
    
    static func getDateFrom(year: Int, month: Int, day: Int) -> Date {
        let comps = NSDateComponents()
        comps.day = day
        comps.month = month
        comps.year = year
        let newDate = NSCalendar.current.date(from: comps as DateComponents)
        return newDate!
    }

    func getDateAddedBy(minutes: Int) -> Date {
        let dateComponents = NSDateComponents()
        dateComponents.minute = minutes

        let newDate = Calendar.current.date(byAdding: dateComponents as DateComponents, to: self)
        return newDate!
    }

    func getDateAddedBy(hours: Int) -> Date {
        let dateComponents = NSDateComponents()
        dateComponents.hour = hours

        let newDate = Calendar.current.date(byAdding: dateComponents as DateComponents, to: self)
        return newDate!
    }
    
    func getDateAddedBy(days: Int) -> Date {
        let dateComponents = NSDateComponents()
        dateComponents.day = days
        
        let newDate = Calendar.current.date(byAdding: dateComponents as DateComponents, to: self)
        return newDate!
    }
    
    func getDateAddedBy(months: Int) -> Date {
        let dateComponents = NSDateComponents()
        dateComponents.month = months
        
        let newDate = Calendar.current.date(byAdding: dateComponents as DateComponents, to: self)
        return newDate!
    }
    
    static func getWeekCountOf(year: Int) -> Int {
        let theFirstWeekDate = Date.getFirstWeekDateInYear(year: year)
        let theFirstWeekDateNextYear = Date.getFirstWeekDateInYear(year: year+1)
        let daysDiff = theFirstWeekDate.numberOfDaysUntilDateTime(toDateTime: theFirstWeekDateNextYear)
        
        if daysDiff == 53 * 7 {
            return 53
        }
        else {
            return 52
        }
    }

    static func getCurrentTimeMills() -> Int64 {
        let now = Date()
        let elapsed = now.timeIntervalSince1970
        return Int64(elapsed*1000)
    }

    static func getDateString(timeMills: Int64) -> String {
        let elapsed = Double(timeMills)/1000
        let date = Date(timeIntervalSince1970: elapsed)
        return date.toDateString(format: "yyyy-MM-dd HH:mm:ss") ?? ""
    }

    static func getDate(timeMills: Int64) -> Date {
        let elapsed = Double(timeMills)/1000
        let date = Date(timeIntervalSince1970: elapsed)
        return date
    }

}

// MARK: -extension for project
extension Date {
    
    var realWeekOfYear: Int {
        let w = self.weekOfYear
        let firstDay = self.firstDayOfTheYear
        let weekday = firstDay.weekday
        if weekday != kWeekdayMonday {
            return w-1
        }
        else {
            return w
        }
    }
    
    var realYear: Int {
        let _year = self.year
        let weekOfYear = self.realWeekOfYear
        if weekOfYear == 0 {
            return _year-1
        }
        return _year
    }
    
    var realQuarter: Int {
        let _weekOfYear = realWeekOfYear-1
        let quarter = _weekOfYear / 13
        if quarter == 4 {
            return 4
        }
        else {
            return quarter+1
        }
    }

    var dayOfYear: Int {
        let dateString = self.toDateString(format: "DDD") ?? ""
        let result = Int(dateString) ?? 0
        return result
    }
    
    func getRealQuarterAndWeek() -> (Int, Int) {
        var _weekOfYear = realWeekOfYear-1
        if _weekOfYear == -1 {
            // this should be last week of the year
            let lastYear = self.year-1
            let lastYearWeekCount = Date.getWeekCountOf(year: lastYear)
            _weekOfYear = lastYearWeekCount-1
        }
        let quarter = _weekOfYear / 13
        var _realQuarter = quarter
        if quarter == 4 {
            _realQuarter = 4
        }
        else {
            _realQuarter = quarter+1
        }
        let _realWeek = (_weekOfYear-(_realQuarter-1)*13)+1
        return (_realQuarter, _realWeek)
    }
    
    func toString() -> String {
        return "\(year).\(month).\(day)"
    }
    
    func toDateString(format: String = "EEE, MMM d, yyyy") -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    static func fromDateString(dateString: String, format: String = "M/d/yyyy") -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString)
    }

    static func fromTimeStamp(timeStamp: Int64) -> Date {
        let elapsed = Double(timeStamp)/1000
        let date = Date(timeIntervalSince1970: elapsed)
        return date
    }

    static func convertDateFormat(dateString: String, fromFormat: String, toFormat: String) -> String {
        if dateString.isEmpty == true {
            return ""
        }
        guard let date = Date.fromDateString(dateString: dateString, format: fromFormat) else {return ""}
        return date.toDateString(format: toFormat) ?? ""
    }

    static func getDaysIn(year: Int, month: Int) -> Int {

        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        return numDays
    }

    func getTimestamp() -> Int64 {
        return Int64(self.timeIntervalSince1970*1000)
    }

    func getNextWorkDay() -> Date {
        var date = self.getDateAddedBy(days: 1)
        while date.isWorkDay() == false {
            date = date.getDateAddedBy(days: 1)
        }
        return date
    }

    func isWorkDay() -> Bool {
        if self.weekday == kWeekdaySunday || self.weekday == kWeekdaySaturday {
            return false
        }
        else {
            return true
        }
    }

    func getJustDay() -> Date {
        let dayString = (self.toDateString(format: "yyyy-MM-dd") ?? "") + "00:00:00"
        let justDay = Date.fromDateString(dateString: dayString, format: "yyyy-MM-ddHH:mm:ss") ?? Date()
        return justDay
    }
}

extension NSDate {
    
    var date: Date {
        return self as Date
    }
}
