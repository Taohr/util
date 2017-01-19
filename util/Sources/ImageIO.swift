/****************************************************************************
 *	@desc	图片
 *	@date	15/11/19
 *	@author	110102
 *	@file	ImageIO.swift
 *	@modify	null
 ******************************************************************************/

import Foundation
import UIKit

/// 根目录
public enum RootPath {
    /// Documents目录, 存放用户数据, 如app设置, 一直存在, 参与备份
    case Document
    /// Library/Caches目录, 存放缓存数据, 如用户头像, 一直存在, 不参与备份
    case Cache
    /// 临时
    case Temp
}

public class ImageIO {
    /// jpg图在保存时的压缩系数
    static public let COMPRESSION_QUALITY: CGFloat = 0.5
    
    //--------------------------------------------------------------------------
    // MARK: - 图片文件I/O
    //--------------------------------------------------------------------------
    /// 保存UIImage
    /// - parameter image:              图片
    /// - parameter folder:             文件夹
    /// - parameter compressionQuality: 压缩质量
    /// - parameter fileName:           保存的文件名
    /// - returns: 文件的完整路径
    /// - note: 从文件名推断, 如果是png, 会保存为png. 如果是其他, 则保存为jpg
    /// - note: 如果出错, 返回nil
    static public func saveImage(image: UIImage, fileName: String, rootPath: RootPath, folder: String = "", compressionQuality: CGFloat = COMPRESSION_QUALITY) -> String? {
        // 根据图片类型做不同处理
        let isPng = fileName.hasSuffix(".png")
        guard let imageData = (isPng ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, compressionQuality)) else {
            return nil
        }
        // 存储路径
        guard let folderURL = NSFileManager.defaultManager().getFolderURL(rootPath, folderName: folder) else {
            return nil
        }
        // 文件路径
        let fileURL = folderURL.URLByAppendingPathComponent(fileName, isDirectory: false)
        guard let filePath = fileURL.path else {
            return nil
        }
        Log.d("\(filePath)")
        imageData.writeToFile(filePath, atomically: true)
        return filePath
    }
    /// 删除指定目录下的文件
    /// - parameter fileName: 文件名. 若为空, 不执行
    /// - parameter rootPath: 根目录
    /// - parameter folder:   子目录. 如 `/photo`, 也可多重路径如 `/user/image`
    /// - returns: 是否删除成功
    static public func deleteFile(fileName: String, rootPath: RootPath, folderName: String) -> Bool {
        if fileName == "" {
            return false
        }
        guard let folderURL = NSFileManager.defaultManager().getFolderURL(rootPath, folderName: folderName, autoCreateIfNotExist: false) else {
            return false
        }
        let fileURL = folderURL.URLByAppendingPathComponent(fileName, isDirectory: false)
        guard let filePath = fileURL.path else {
            return false
        }
        Log.d("\(filePath)")
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
            return true
        } catch {
            return false
        }
    }
    /// 删除指定目录下指定的子目录
    /// - parameter rootPath:   根目录
    /// - parameter folderName: 文件夹名称. 若为空, 不执行
    /// - returns: 是否删除成功
    /// - note: folderName 可以是单重路径如 `photo`, 也可多重路径如 `user/image`
    /// - note: 假设 folderName 是`user/image`, 删除成功后, `image`目录被移除, 还剩下`user`目录
    static public func deleteFolder(rootPath: RootPath, folderName: String) -> Bool {
        if folderName == "" {
            return false
        }
        guard let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains:.UserDomainMask).first else {
            return false
        }
        let folderURL = directoryURL.URLByAppendingPathComponent(folderName, isDirectory: true)
        guard let folderPath = folderURL.path else {
            return false
        }
        do {
            try NSFileManager.defaultManager().removeItemAtPath(folderPath)
            return true
        } catch {
            return false
        }
    }
    /// 清空指定目录内的文件
    /// - parameter rootPath:   根目录
    /// - parameter folderName: 文件夹名称. 若为空, 不执行
    /// - returns: 是否清空成功
    /// - note: folderName 可以是单重路径如 `photo`, 也可多重路径如 `user/image`
    static public func cleanFolder(rootPath: RootPath, folderName: String) -> Bool {
        if folderName == "" {
            return false
        }
        guard let folderURL = NSFileManager.defaultManager().getFolderURL(rootPath, folderName: folderName, autoCreateIfNotExist: false) else {
            return false
        }
        guard let folderPath = folderURL.path else {
            return false
        }
        do {
            let files = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(folderPath)
            Log.d("\(files)")
            for file in files {
                let pathURL = folderURL.URLByAppendingPathComponent(file)
                guard let path = pathURL.path else {
                    continue
                }
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(path)
                } catch {
                    continue
                }
            }
            return true
        } catch {
            return false
        }
    }
}
