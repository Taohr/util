/****************************************************************************
 *	@desc	Extension+NSFileManager
 *	@date	2017/1/19
 *	@author	110102
 *	@file	Extension+NSFileManager.swift
 *	@modify	null
 ******************************************************************************/

import Foundation

// MARK: - NSFileManager

extension NSFileManager {
    /// Documents
    public var documentsURL: NSURL {
        get {
            return self.URLsForDirectory(.DocumentDirectory, inDomains:.UserDomainMask).first!
        }
    }
    /// Library/Caches
    public var cachesURL: NSURL {
        get {
            return self.URLsForDirectory(.CachesDirectory, inDomains:.UserDomainMask).first!
        }
    }
    ///
    public var tempURL: NSURL {
        get {
            return NSURL(fileURLWithPath: NSTemporaryDirectory())
        }
    }
    /// 获取指定根目录下的子目录url
    /// - parameter rootPath:   根目录url
    /// - parameter folderName: 子目录
    /// - parameter autoCreate: 如果子目录不存在, 是否自动创建
    /// - returns: 子目录的url. 如果获取失败, 返回nil
    public func getFolderURL(rootPath: RootPath, folderName: String, autoCreateIfNotExist autoCreate: Bool = true) -> NSURL? {
        var rootPathURL: NSURL
        switch rootPath {
        case RootPath.Document:
            rootPathURL = self.documentsURL
        case RootPath.Cache:
            rootPathURL = self.cachesURL
        case RootPath.Temp:
            rootPathURL = self.tempURL
        }
        if folderName == "" {
            return nil
        }
        let url = rootPathURL.URLByAppendingPathComponent(folderName, isDirectory: true)
        if autoCreate {
            if false == createFolderWithURL(url) {
                return nil
            }
        }
        return url
    }
    /// 创建url指定的目录
    /// - parameter url: 指定目录
    /// - returns: 是否创建成功. 如果已存在, 也返回true
    private func createFolderWithURL(url: NSURL) -> Bool {
        guard let path = url.path else {
            return false
        }
        if false == self.fileExistsAtPath(path) {
            do {
                try self.createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch {
                Log.e(error)
                return false
            }
        }
        return true
    }
}
