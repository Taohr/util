/****************************************************************************
 *	@desc	Delay
 *	@date	2017/1/19
 *	@author	110102
 *	@file	Delay.swift
 *	@modify	null
 ******************************************************************************/

import Foundation

/// 延时执行一个方法
public func delay(time: Double, function: ()->()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        NSThread.sleepForTimeInterval(time)
        dispatch_async(dispatch_get_main_queue(), {
            function()
        })
    })
}

/// 分线程执行
public func run(onGlobalQueue global: ()->(AnyObject?), onMainQueue main: (AnyObject?)->()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        let object = global()// 耗时代码
        dispatch_async(dispatch_get_main_queue(), {
            main(object)// 返回主线程
        })
    })
}