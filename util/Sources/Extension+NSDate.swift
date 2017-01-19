/****************************************************************************
 *	@desc	Extension+NSDate
 *	@date	2017/1/19
 *	@author	110102
 *	@file	Extension+NSDate.swift
 *	@modify	null
 ******************************************************************************/

import Foundation

// MARK: - NSDate

extension NSDate {
    static public var now: NSTimeInterval {
        get {
            return NSDate().timeIntervalSince1970
        }
    }
    /// 昨天、今天、明天、xx号
    public var relativeDate: String {
        get {
            let deltaMax: Int = 1// 2 //相差一（两）天，超出的则显示那天的日期
            let selfref = self
            let today = NSDate()
            let calendar = NSCalendar.currentCalendar()
            guard let aDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: selfref, options: .WrapComponents), let bDate = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: today, options: .WrapComponents) else {
                return ""
            }
            let matrix = [
                // 更早的则显示那天的日期
                -2 : "前天",
                -1 : "昨天",
                0 : "今天",
                1 : "明天",
                2 : "后天",
                // 更晚的则显示那天的日期
            ]
            var dayString: String? = nil
            let components = calendar.components(NSCalendarUnit.Day, fromDate: bDate, toDate: aDate, options: .WrapComponents)
            let deltaDay = components.day
            dayString = abs(deltaDay) > deltaMax ? nil : matrix[deltaDay]
            if dayString == nil {
                let components = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: aDate)
                components.timeZone = NSTimeZone.localTimeZone()
                dayString = String(format: "%02d号", components.day)
            }
            return dayString ?? ""
        }
    }
}

// MARK: - NSDateFormatter

public let YearMonthDate_HourMinuteSecond = "YYYY-MM-dd HH:mm:ss"
extension NSDateFormatter {
    /// 创建一个日期格式化器
    /// - parameter format: 格式化字符串
    /// - returns: NSDateFormatter
    static public func create(withFormat format: String = YearMonthDate_HourMinuteSecond) -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = NSTimeZone.localTimeZone()
        return formatter
    }
    /// 获取日期的字符串格式
    /// - parameter date:   日期
    /// - parameter format: 字符串格式
    /// - returns: String
    static public func getDateString(fromDate date: NSDate, withDateFormat format: String = YearMonthDate_HourMinuteSecond) -> String {
        let formatter = NSDateFormatter.create(withFormat: format)
        let dateString = formatter.stringFromDate(date)
        return dateString
    }
    /// 获取日期
    /// - parameter dateString: 日期字符串
    /// - returns: NSDate
    static public func getDate(fromDateString dateString: String, withDateFormat format: String = YearMonthDate_HourMinuteSecond) -> NSDate? {
        let formatter = NSDateFormatter.create(withFormat: format)
        let date = formatter.dateFromString(dateString)
        return date
    }
}

// MARK: - NSDateComponents

extension NSDateComponents {
    /// 获取日期中的年月
    /// - parameter dateString: 日期字符串
    /// - returns: NSDateComponents?
    static public func getDateComponents(fromDateString dateString: String, withDateFormat format: String = YearMonthDate_HourMinuteSecond) -> NSDateComponents? {
        guard let date = NSDateFormatter.getDate(fromDateString: dateString, withDateFormat: format) else {
            return nil
        }
        return NSDateComponents.getDateComponents(fromDate: date)
    }
    /// 获取日期中的年月
    /// - parameter date: 日期
    /// - returns: NSDateComponents
    static public func getDateComponents(fromDate date: NSDate) -> NSDateComponents {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: date)
        components.timeZone = NSTimeZone.localTimeZone()
        return components
    }
}

