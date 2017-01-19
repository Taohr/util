/****************************************************************************
 *	@desc	弹窗
 *	@date	15/12/21
 *	@author	110102
 *	@file	Alert.swift
 *	@modify	null
 ******************************************************************************/

import UIKit

typealias AlertCallback = (selectedIndex: Int, cancelled: Bool)->()

class Alert {
    /// 简单信息提示
    /// - parameter viewController: 要显示弹窗的视图控制器
    /// - parameter title:          标题
    /// - parameter message:        内容
    /// - parameter followAction:   接下来的操作（只有一个关闭按钮，点击关闭按钮后，就执行这个操作）
    static func showAlert(viewController: UIViewController?, title: String? = nil, message: String?, followAction: (()->())? = nil) {
        guard let vc = viewController else {
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        //cancel
        let cancelAction = UIAlertAction(title: "ok".localizedString, style: UIAlertActionStyle.Cancel) { (action: UIAlertAction) -> Void in
            followAction?()
        }
        alertController.addAction(cancelAction)
        vc.presentViewController(alertController, animated: true, completion: nil)
    }
    static func d(viewController: UIViewController? = nil, title: String? = nil, message: String?, followAction: (()->())? = nil) {
        if Log.enabled {
            Log.d("title:  \(title ?? "")\nmessage:\(message ?? "")")
            var vc = viewController
            if viewController == nil {
                vc = UIApplication.sharedApplication().getCurrentViewController()
            }
            Alert.showAlert(vc, title: title, message: message, followAction: followAction)
        }
    }
    static func todo(viewController: UIViewController? = nil, message: String?) {
        if Log.enabled {
            var vc = viewController
            if viewController == nil {
                vc = UIApplication.sharedApplication().getCurrentViewController()
            }
            Alert.showAlert(vc, title: "TODO", message: message)
        }
    }
    
    /// 多选一
    /// - parameter viewController: 要显示弹窗的视图控制器
    /// - parameter style:          提示类型
    /// - parameter title:          标题, 可为nil
    /// - parameter selections:     选项
    /// - parameter cancel:         取消按钮, 可为nil
    /// - parameter callback:       回调方法
    /// - note: 回调方法中的`selectedIndex`取值:
    ///     - -1: 表示取消, 可以忽略
    ///     - 0以及其他: 索引
    /// - note: 回调方法中的`cancelled`取值:
    ///     - true: 用户取消了
    ///     - false: 用户选择了
    static func showAlert(viewController: UIViewController, style: UIAlertControllerStyle = UIAlertControllerStyle.Alert, title: String? = nil, message: String? = nil, selections: [String], destruct: [Int] = [], cancel: String? = nil, callback: AlertCallback) {
        let alertController = Alert.createAlertController(style, title: title, message: message, selections: selections, destruct: destruct, cancel: cancel, callback: callback)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    /// 创建一个弹窗
    /// - parameter style:      提示类型
    /// - parameter title:      标题, 可为nil
    /// - parameter message:    信息, 可为nil
    /// - parameter selections: 选项
    /// - parameter destruct:   重要的选项的索引，对应 selections 参数来看
    /// - parameter cancel:     取消按钮, 可为nil
    /// - parameter callback:   回调方法
    /// - note: 回调方法中的`selectedIndex`取值:
    ///     - -1: 表示取消, 可以忽略
    ///     - 0以及其他: 索引
    /// - note: 回调方法中的`cancelled`取值:
    ///     - true: 用户取消了
    ///     - false: 用户选择了
    /// - returns: UIAlertController
    static func createAlertController(style: UIAlertControllerStyle = UIAlertControllerStyle.Alert, title: String? = nil, message: String? = nil, selections: [String], destruct: [Int] = [], cancel: String? = nil, callback: AlertCallback) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        //cancel
        if cancel != nil {
            let cancelAction = UIAlertAction(title: cancel, style: UIAlertActionStyle.Cancel) {
                (action: UIAlertAction) -> Void in
                // 取消的回调, `-1`可以忽略
                callback(selectedIndex: -1, cancelled: true)
            }
            alertController.addAction(cancelAction)
        }
        //selections
        for i in 0..<selections.count {
            let style = destruct.contains(i) ? UIAlertActionStyle.Destructive : UIAlertActionStyle.Default
            let action = UIAlertAction(title: selections[i], style: style) {
                (action: UIAlertAction) -> Void in
                // 选择的回调
                callback(selectedIndex: i, cancelled: false)
            }
            alertController.addAction(action)
        }
        return alertController
    }
    /// 弹窗询问是否重做某个操作
    /// - parameter viewController: 视图控制器
    /// - parameter title:          标题
    /// - parameter message:        内容
    /// - parameter button:         确认按钮
    /// - parameter cancel:         取消按钮
    /// - parameter action:         操作
    static func retryAction(viewController: UIViewController, title: String? = nil, message: String? = nil, button: String, cancel: String, action: (()->())) {
        Alert.showAlert(viewController, style: UIAlertControllerStyle.Alert, title: title, message: message, selections: [button], cancel: cancel) { (selectedIndex, cancelled) in
            if cancelled == false {
                action()
            }
        }
    }
}
