/****************************************************************************
 *	@desc	自定义文本框
 *	@date	2017/1/19
 *	@author	110102
 *	@file	HXTextField.swift
 *	@modify	null
 ******************************************************************************/

import Foundation

public class HXTextField : UITextField {
    /// 是否允许长按显示菜单
    public var canPerformAction: Bool = true
    override public func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        UIMenuController.sharedMenuController().menuVisible = canPerformAction
        return canPerformAction
    }
}