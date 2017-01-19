/****************************************************************************
 *	@desc	Extension+JSON
 *	@date	2017/1/19
 *	@author	110102
 *	@file	Extension+JSON.swift
 *	@modify	null
 ******************************************************************************/

import Foundation

// MARK: - JSON

/**
 需要 SwiftyJSON 库的支持

extension JSON {
    /// 从资源文件获取json数据
    /// - parameter fileName: 文件名, 带后缀
    /// - returns: JSON
    /// - note: 若失败, 返回nil
    static public func getJsonFromResourcesFile(fileName: String) -> JSON {
        guard let file = NSBundle.mainBundle().pathForResource(fileName, ofType: nil) else {
            return nil
        }
        guard let jsonData = NSData(contentsOfFile: file) else {
            return nil
        }
        let json = JSON(data: jsonData)
        return json
    }
}
 */
