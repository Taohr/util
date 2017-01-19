/****************************************************************************
 *	@desc	可拖拽排序的CollectionView
 *	@date	15/12/23
 *	@author	110102
 *	@file	RangeCollectionPlugin.swift
 *	@modify	null
 ******************************************************************************/

import UIKit

public protocol RangeCollectionDelegate : NSObjectProtocol {
    /// 移动数据
    /// - parameter fromIndexPath: 从何处
    /// - parameter toIndexPath:   到何处
    func moveDataSourceItem(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    /// 是否可以进行拖拽操作
    /// - parameter indexPath: 当前位置
    /// - returns: Bool
    /// - note: 某些单元格不应当参与拖拽操作, 则应当返回false
    func dragShouldBegin(atIndexPath indexPath: NSIndexPath) -> Bool
}

/// 1. 在UICollectionView所在的UIViewController里实例化, 并保持(可以作为属性来保持)
/// 2. 实现RangeCollectionDelegate中的方法
public class RangeCollectionPlugin : NSObject, UIGestureRecognizerDelegate {
    //--------------------------------------------------------------------------
    // MARK: - init
    //--------------------------------------------------------------------------
    /// 初始化
    /// - parameter collectionView: 集合视图
    /// - parameter delegate:       代理
    public init(collectionView: UICollectionView, delegate: RangeCollectionDelegate) {
        self.collectionView = collectionView
        self.delegate = delegate
        super.init()
        addGesture()
    }
    deinit {
        delegate = nil
        removeGesture()
        Log.d()
    }
    //--------------------------------------------------------------------------
    // MARK: - action
    //--------------------------------------------------------------------------
    /// 手势被识别, 可以进行手势处理
    @objc func gestureRecognized(gesture: UIGestureRecognizer) {
        guard self.bundle != nil else {
            return
        }
        let alpha: CGFloat = 0.1
        switch gesture.state {
        case UIGestureRecognizerState.Began:
            // 调整UI显示效果
            self.bundle!.sourceCell.alpha = alpha
            self.bundle!.canvas.addSubview(self.bundle!.representationImageView)
            self.bundle!.representationImageView.alpha = 0.5
        case UIGestureRecognizerState.Changed:
            // 实时调整镜像单元格的位置
            let dragPointOnCanvas = gesture.locationInView(self.bundle!.canvas)
            let point = CGPointMake(dragPointOnCanvas.x - self.bundle!.offset.x, dragPointOnCanvas.y - self.bundle!.offset.y)
            self.bundle!.representationImageView.frame.origin = point
            // 获取当前触点所在位置
            guard let indexPath = self.collectionView.indexPathForItemAtPoint(gesture.locationInView(self.collectionView)) else {
                return
            }
            if let delegate = self.delegate {
                if false == delegate.dragShouldBegin(atIndexPath: indexPath) {
                    return
                }
            }
            if false == indexPath.isEqual(self.bundle!.currentIndexPath) {
                // 更新数据和界面
                self.delegate?.moveDataSourceItem(self.bundle!.currentIndexPath, toIndexPath: indexPath)
                self.collectionView.moveItemAtIndexPath(self.bundle!.currentIndexPath, toIndexPath: indexPath)
                self.bundle!.sourceCell.alpha = alpha
                self.bundle!.currentIndexPath = indexPath
            }
        case UIGestureRecognizerState.Ended:
            // 坐标系转换
            let frame = self.bundle!.canvas.convertRect(self.bundle!.sourceCell.frame, fromView: self.bundle!.sourceCell.superview)
            // 镜像单元格归位, 动画
            UIView.beginAnimations("move_cell", context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDidStopSelector(#selector(RangeCollectionPlugin.moveDidStop(_:finished:)))
            self.bundle!.representationImageView.frame = frame
            UIView.commitAnimations()
        default:
            break
        }
    }
    /// 图片移动结束后的回调
    @objc func moveDidStop(anim: CAAnimation, finished flag: Bool) {
        self.bundle!.sourceCell.alpha = 1.0
        self.bundle!.representationImageView.removeFromSuperview()
        self.bundle = nil
        self.collectionView.reloadData()
    }
    //--------------------------------------------------------------------------
    // MARK: - UIGestureRecognizerDelegate
    //--------------------------------------------------------------------------
    /// 检查手势触点, 判断是否可以执行手势的处理
    public func gestureRecognizerShouldBegin(gesture: UIGestureRecognizer) -> Bool {
        guard let canvas = collectionView.superview else {
            return false
        }
        // 统一坐标系, 然后遍历查找被长按的单元格
        // 如果没找到, 不进行手势处理
        // 如果找到, 记录相关数据
        let pointPressedInCanvas = gesture.locationInView(canvas)
        for cell in collectionView.visibleCells() {
            let cellInCanvasFrame = canvas.convertRect(cell.frame, fromView: collectionView)
            if CGRectContainsPoint(cellInCanvasFrame, pointPressedInCanvas) {
                guard let indexPath = collectionView.indexPathForCell(cell) else {
                    return false
                }
                if let delegate = self.delegate {
                    if false == delegate.dragShouldBegin(atIndexPath: indexPath) {
                        return false
                    }
                }
                let representationImage = cell.snapshotViewAfterScreenUpdates(true)
                representationImage.frame = cellInCanvasFrame
                let offset = CGPointMake(pointPressedInCanvas.x - cellInCanvasFrame.origin.x, pointPressedInCanvas.y - cellInCanvasFrame.origin.y)
                self.bundle = Bundle(offset: offset, sourceCell: cell, representationImageView: representationImage, currentIndexPath: indexPath, canvas: canvas)
                break
            }
        }
        return (self.bundle != nil)
    }
    //--------------------------------------------------------------------------
    // MARK: - private methods
    //--------------------------------------------------------------------------
    /// 添加手势
    private func addGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(RangeCollectionPlugin.gestureRecognized(_:)))
        gesture.minimumPressDuration = 0.2
        gesture.delegate = self
        collectionView.addGestureRecognizer(gesture)
    }
    private func removeGesture() {
        if let gestures = collectionView.gestureRecognizers {
            for gesture in gestures {
                collectionView.removeGestureRecognizer(gesture)
            }
        }
    }
    //--------------------------------------------------------------------------
    // MARK: - private variables
    //--------------------------------------------------------------------------
    /// 要进行排序的CollectionView
    private var collectionView: UICollectionView
    /// 代理, 负责更新数据
    private weak var delegate: RangeCollectionDelegate? = nil
    /// 存储拖拽状态的数据
    private var bundle: Bundle?
    //--------------------------------------------------------------------------
    // MARK: - private struct
    //--------------------------------------------------------------------------
    /// 存储拖拽操作的相关信息
    private struct Bundle {
        /// 触摸点偏移量
        var offset = CGPointZero
        /// 单元格
        var sourceCell: UICollectionViewCell
        /// 单元格镜像图
        var representationImageView: UIView
        /// 单元格当前的位置
        var currentIndexPath: NSIndexPath
        /// 单元格镜像图的容器
        var canvas: UIView
    }
}
