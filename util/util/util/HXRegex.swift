/****************************************************************************
 *	@desc	正则
 *	@date	2017/1/17
 *	@author	110102
 *	@file	HXRegex.swift
 *	@modify	null
 ******************************************************************************/

import Foundation

public class HXRegex {
    private let regex: NSRegularExpression?
    
    public init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
    }
    
    public func match(input: String) -> Bool {
        if let matches = regex?.matchesInString(input, options: [], range: NSMakeRange(0, (input as NSString).length)) {
            return matches.count > 0
        }
        else {
            return false
        }
    }
}