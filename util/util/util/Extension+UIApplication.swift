/****************************************************************************
 *	@desc	Extension+UIApplication
 *	@date	2017/1/19
 *	@author	110102
 *	@file	Extension+UIApplication.swift
 *	@modify	null
 ******************************************************************************/

import Foundation

// MARK: - UIApplication

extension UIApplication {
    /// 获取当前的视图控制器
    /// - returns: UIViewController?
    public func getCurrentViewController() -> UIViewController? {
        var current: UIViewController? = nil
        var window = UIApplication.sharedApplication().keyWindow
        if window?.windowLevel != UIWindowLevelNormal {
            let windows = UIApplication.sharedApplication().windows
            for win in windows {
                if win.windowLevel == UIWindowLevelNormal {
                    window = win
                    break
                }
            }
        }
        let frontView = window?.subviews.first
        let nextResponder = frontView?.nextResponder()
        if let vc = nextResponder as? UIViewController {
            current = vc
        } else {
            current = window?.rootViewController
        }
        return current
    }
    /// 获取当前present出来的视图控制器
    /// - returns: UIViewController?
    public func getPresentedViewController() -> UIViewController? {
        let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        let topVC = rootVC?.presentedViewController ?? rootVC
        return topVC
    }
    /// 获取应用的名称
    /// - returns: String?
    public func getAppName() -> String? {
        let info = NSBundle.mainBundle().infoDictionary
        let name = info?["CFBundleDisplayName"] as? String
        return name
    }
    /// 获取应用的版本号
    /// - returns: String?
    public func getAppVersion() -> String? {
        let info = NSBundle.mainBundle().infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String
        return version
    }
    /// 获取应用的build版本号
    /// - returns: String?
    public func getAppBuild() -> String? {
        let info = NSBundle.mainBundle().infoDictionary
        let build = info?["CFBundleVersion"] as? String
        return build
    }
}

