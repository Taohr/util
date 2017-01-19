/****************************************************************************
 *	@desc	取UUID
 *	@date	15/11/10
 *	@author	110102
 *	@file	UUID.swift
 *	@modify	null
 ******************************************************************************/

import Foundation

/**
 和`KeychainAccessGroups.plist`里的一样!
 类似`EJ5AF5765Q.com.mogo.yuefou`
 在Provisioning Profile中查看
 不可以修改
 存储于Keychain中, 刷机会抹去记录, 删除重装app不会
 */

func getUUID(accessGroup: String) -> String {
    let keychainItem = KeychainItemWrapper(identifier: "UUID", accessGroup: accessGroup)
    let cfstrUUID = keychainItem.objectForKey(kSecAttrService)
    var UUID: String = ""
    if (cfstrUUID != nil) {
        UUID = cfstrUUID as! String
    }
    if UUID == "" {
        let uuidRef = CFUUIDCreate(kCFAllocatorDefault)
        UUID = CFUUIDCreateString(kCFAllocatorDefault, uuidRef) as String
        keychainItem.setObject(UUID, forKey: kSecAttrService)
    }
    return UUID
}

