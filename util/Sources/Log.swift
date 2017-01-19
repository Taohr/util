/****************************************************************************
 *	@desc	日志
 *	@date	15/11/10
 *	@author	110102
 *	@file	Log.swift
 *	@modify	null
 ******************************************************************************/

import Foundation
import UIKit

public class Log {
    static public var enabled = false

    static public func d(log: AnyObject? = nil, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
        if enabled {
            let shortFile = (file as NSString).lastPathComponent
            let prefix = String(count: 80, repeatedValue: Character("-"))
            let content: AnyObject = log ?? ""
            let string = "\(prefix)\n\(shortFile) | \(line) | \(function)\n\(content)"
            print(string)
        }
    }
    /**
     do-try-catch的错误输出
     */
    static public let ERR_TAG = "__DO_TRY_CATCH_ERROR__"
    static public func e(error: ErrorType, _ file: String = #file, _ line: Int = #line, _ function: String = #function){
        if enabled {
            let shortFile = (file as NSString).lastPathComponent
            print("\(ERR_TAG)\n\(shortFile) | \(line) | \(function)\n\(error)")
        }
    }
}

public class Paste {
    static public var enabled = false
    /**
     剪贴板
     */
    static public func PLogReset() {
        if enabled {
            let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String ?? "[?]"
            let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String ?? "[?]"
            dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            let timeString = dateFormatter.stringFromDate(NSDate())
            pasteString = "v\(version)_b\(build)\n"
            pasteString += "\(timeString)"
        }
    }
    static public func fresh() {
        if enabled {
            UIPasteboard.generalPasteboard().string = pasteString
        }
    }
    static public func PLog(log: AnyObject? = nil, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
        if enabled {
            let shortFile = (file as NSString).lastPathComponent
            let prefix = "[P]" + String(count: 77, repeatedValue: Character("-"))
            let content: AnyObject = log ?? ""
            let string = "\n\(prefix)\n\(shortFile) | \(line) | \(function)\n\(content)\n"
            pasteString += string
            Log.d(log, file, line, function)
        }
    }
    static private var pasteString = ""
    static private var dateFormatter: NSDateFormatter! = nil
}
