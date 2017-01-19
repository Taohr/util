/****************************************************************************
 *	@desc	Extension+NSURL
 *	@date	2017/1/19
 *	@author	110102
 *	@file	Extension+NSURL.swift
 *	@modify	null
 ******************************************************************************/

import Foundation

// MARK: - NSURL

extension NSURL {
    public func getParameters() -> [String : AnyObject] {
        let query = self.query ?? ""
        return query.getParameters()
    }
    
    /// 从URL获取文件名
    /// - returns: 文件名
    /// - note: 返回空字符串表示获取文件名失败
    public func getFileName() -> String {
        guard let path = self.path else {
            return ""
        }
        let components = path.componentsSeparatedByString("/")
        guard let fileName = components.last else {
            return ""
        }
        return fileName
    }

}

