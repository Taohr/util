/****************************************************************************
 *	@desc	操作符扩展
 *	@date	15/12/4
 *	@author	110102
 *	@file	Operator.swift
 *	@modify	null
 ******************************************************************************/

import Foundation

// MARK: - CGRect

/// CGRect乘法
/// - parameter rect:  rect
/// - parameter value: 倍数
/// - returns: CGRect
public func * (rect: CGRect, value: CGFloat) -> CGRect {
    var ret = rect
    ret.origin.x *= value
    ret.origin.y *= value
    ret.size.width *= value
    ret.size.height *= value
    return ret
}
/// CGRect除法
/// - parameter rect:  rect
/// - parameter value: 除数
/// - returns: CGRect
/// - note: 除数不能为0
public func / (rect: CGRect, value: CGFloat) -> CGRect {
    guard value != 0 else {
        return rect
    }
    return rect * (1/value)
}

// MARK: - <<< operator
infix operator <<< {
    associativity none
    precedence 160
}
/// 把值赋值给自己。
/// 本身有设置didSet操作才有意义
public func <<< <T>(inout left: T, right: T) {
    let temp = right
    left = temp
}