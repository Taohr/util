/****************************************************************************
 *	@desc	类的扩展
 *	@date	15/12/4
 *	@author	110102
 *	@file	Extensions.swift
 *	@modify	null
 ******************************************************************************/

import Foundation

 
// MARK: - UIImageView

extension UIImageView {
    /**
 
     需要AlamofireImage支持
 
    /// 缓存
    /// - note: app进程结束后, 缓存会清空
    static let cache = AutoPurgingImageCache()
    /// 用URL指定的图片设置UIImageView
    /// - parameter imageUrl:         图片url地址
    /// - parameter placeholderImage: 占位图
    /// - parameter rootPath:         保存至本地的指定根目录
    /// - parameter folderName:       保存至本地的指定子目录
    /// 1. 找缓存 (通过AutoPurgingImageCache查找缓存的图片, 若有, 直接使用)
    /// 2. 找本地 (查找本地是否有保存此图片, 若有, 直接使用)
    /// 3. 下载 (通过AlamofireImage下载图片, 完成后, 缓存+保存到本地)
    /// - note: 图片下载后默认保存到`Library/Caches`目录下，文件夹名称需指定
    /// - note: 缓存仅限本次app进程期间. 结束进程则缓存清空(以目前运行的结果推断是这样)
    public func setImageWithURLAndCache(imageUrl: String, placeholderImage: UIImage?, rootPath: RootPath = RootPath.Cache, folderName: String) {
        if imageUrl == "" {
            self.image = nil
            return
        }
        guard let url = NSURL(string: imageUrl) else {
            self.image = nil
            return
        }
        var fileName = url.getFileName()
        if fileName == ""{
            // 没得到有效文件名, 用图片地址的md5值代替
            fileName = imageUrl.md5String
        }
        // 1
        repeat {
            guard let cachedImage = UIImageView.cache.imageWithIdentifier(fileName) else {
                break
            }
            self.image = cachedImage
            return
        } while (false)
        // 2
        repeat {
            guard let folderPath = NSFileManager.defaultManager().getFolderURL(rootPath, folderName: folderName) else {
                break
            }
            let filePath = folderPath.URLByAppendingPathComponent(fileName, isDirectory: false)
            guard let pathString = filePath.path else {
                break
            }
            if false == NSFileManager.defaultManager().fileExistsAtPath(pathString) {
                break
            }
            self.setImageWithContentsOfFile(pathString)
            return
        } while(false)
        // 3
        self.af_setImageWithURL(url, placeholderImage: placeholderImage, filter: nil, imageTransition: .None) {
            (response: Response<UIImage, NSError>) -> Void in
            guard response.result.isSuccess else {
                return
            }
            guard let image = response.result.value else {
                return
            }
            UIImageView.cache.addImage(image, withIdentifier: fileName)
            Image.saveImage(image, fileName: fileName, rootPath: rootPath, folder: folderName)
        }
    }
    /// 从文件读取图片
    /// - parameter path: 图片完整路径
    /// - note: 多线程
    public func setImageWithContentsOfFile(path: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // 耗时代码
            guard let localImage = UIImage(contentsOfFile: path) else {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                // 返回主线程
                self.image = localImage
            })
        })
    }
     */
}



// MARK: - UIView

extension UIView {
    /// 移除所有子视图
    public func removeAllSubviews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    /// 第一响应view
    public func firstResponder() -> UIView? {
        if self.isFirstResponder() {
            return self
        }
        for view in self.subviews {
            if let firstResponder = view.firstResponder() {
                return firstResponder
            }
        }
        return nil
    }
    /// 最近一个ScrollView父容器
    public func getNearestSuperScrollView() -> UIScrollView? {
        var scrollView: UIScrollView? = nil
        var view = self.superview
        while view != nil {
            if let scroll = view as? UIScrollView {
                scrollView = scroll
                break
            }
            view = view!.superview
        }
        return scrollView
    }
    /// 闪烁红色提醒
    public func flashRed() {
        removeRedFlash()
        UIView.beginAnimations("flashRed", context: nil)
        UIView.setAnimationDuration(0.1)
        UIView.setAnimationRepeatCount(2)
        UIView.setAnimationRepeatAutoreverses(true)
        self.backgroundColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.3)
        UIView.commitAnimations()
    }
    /// 移除红色闪烁
    /// - TODO: 未考虑到原本的背景色需要恢复的情况
    public func removeRedFlash() {
        self.backgroundColor = nil
    }
    /// UIView 转换成 UIImage
    /// - returns: UIImage
    public func toImage() -> UIImage {
        var image:UIImage
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.mainScreen().scale)
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.renderInContext(context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        } else {
            image = UIImage()
        }
        UIGraphicsEndImageContext()
        return image
    }
    /// 水平排列views，间隔固定，容器宽度固定。每行居中
    /// 换行，行距固定。容器高度会适应views
    /// - parameter views: 要排列的view
    public func layoutViews(views: [UIView], marginY: CGFloat, spacing: CGFloat, lineSpacing: CGFloat) {
        var currentTop: CGFloat = marginY
        var start: Int = 0
        let end: Int = views.count - 1
        let container = self
        // for
        while (start <= end) {
            // new line
            var viewsInLine: [UIView] = []
            var maxHeight: CGFloat = 0
            var viewsWidth: CGFloat = 0
            let tempStart = start
            for i in tempStart...end {
                let view = views[i]
                let tmpWidth = viewsWidth + view.frame.size.width + ((viewsInLine.count == 0) ? 0 : spacing)
                if tmpWidth < container.frame.size.width {
                    viewsInLine.append(view)
                    start = i + 1
                    maxHeight = max(maxHeight, view.frame.size.height)
                    viewsWidth = tmpWidth
                } else {
                    if viewsInLine.isEmpty {
                        viewsInLine.append(view)
                        start = i + 1
                        maxHeight = max(maxHeight, view.frame.size.height)
                    }
                    break//to next line
                }
            }//for
            // add views in one line
            let centerY = currentTop + maxHeight/2
            if viewsInLine.count == 1 {
                let view = viewsInLine.first!
                view.center = CGPointMake(container.frame.size.width/2, centerY)
                container.addSubview(view)
            } else {
                var lastLeft: CGFloat = container.frame.size.width/2 - viewsWidth/2
                for view in viewsInLine {
                    let centerX = lastLeft + view.frame.size.width/2
                    view.center = CGPointMake(centerX, centerY)
                    container.addSubview(view)
                    lastLeft = lastLeft + view.frame.size.width + spacing
                }
            }
            currentTop = currentTop + maxHeight + lineSpacing
        }//while
        // reach the bottom
        currentTop = currentTop - lineSpacing + marginY
        container.frame.size.height = currentTop
    }
    
    public func layoutVertical(spacing spacing: CGFloat = 0, reverse: Bool = false) {
        let views = reverse ? self.subviews.reverse() : self.subviews
        // frame
        var width: CGFloat = 0
        var height: CGFloat = 0
        for view in views {
            width = max(view.frame.size.width, width)
            height += view.frame.size.height + spacing
        }
        height -= spacing//最后一个不需要
        self.frame.size = CGSizeMake(width, height)
        // position
        var pre: UIView? = nil
        for view in views {
            view.center.x = self.frame.size.width/2
            if pre == nil {
                view.frame.origin.y = 0
            } else {
                view.frame.origin.y = pre!.frame.origin.y + pre!.frame.size.height + spacing
            }
            pre = view
        }
    }
    
    public func layoutHorizontal(spacing spacing: CGFloat = 0, reverse: Bool = false) {
        let views = reverse ? self.subviews.reverse() : self.subviews
        // frame
        var width: CGFloat = 0
        var height: CGFloat = 0
        for view in views {
            width += view.frame.size.width + spacing
            height = max(view.frame.size.height, height)
        }
        width -= spacing//最后一个不需要
        self.frame.size = CGSizeMake(width, height)
        // position
        var pre: UIView? = nil
        for view in views {
            view.center.y = self.frame.size.height/2
            if pre == nil {
                view.frame.origin.x = 0
            } else {
                view.frame.origin.x = pre!.frame.origin.x + pre!.frame.size.width + spacing
            }
            pre = view
        }
    }
}

// MARK: - UIImage

extension UIImage {
    /// 裁切图片
    /// - parameter rect: 裁切区域
    /// - returns: UIImage
    /// - note: 新图 = 原图 ∩ 裁切区域
    public func clip(rect: CGRect) -> UIImage {
        guard let clippedImageRef = CGImageCreateWithImageInRect(self.CGImage, rect) else {
            return self
        }
        let clippedRect = CGRectMake(0, 0, CGFloat(CGImageGetWidth(clippedImageRef)), CGFloat(CGImageGetHeight(clippedImageRef)))
        UIGraphicsBeginImageContext(clippedRect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawImage(context, clippedRect, clippedImageRef)
        let clippedImage = UIImage(CGImage: clippedImageRef)
        UIGraphicsEndImageContext()
        return clippedImage
    }
    /// 九宫格图片
    static public func resizableImage(name: String, edgeInsets: UIEdgeInsets = UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5)) -> UIImage? {
        return UIImage(named: name)?.resizableImage(edgeInsets)
    }
    /// 可缩放的九宫格图片
    /// - parameter edgeInset: 缩放部分的区域（一般就是中间部分，用于缩放或平铺；其余部分就是圆角及四边）
    /// - parameter mode:      缩放模式，参考`UIImageResizingMode`，拉伸或平铺
    /// - returns: UIImage
    public func resizableImage(edgeInset: UIEdgeInsets = UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5), mode: UIImageResizingMode = UIImageResizingMode.Tile) -> UIImage {
        let inset = UIEdgeInsetsMake(self.size.height * edgeInset.top, self.size.width * edgeInset.left, self.size.height * edgeInset.bottom, self.size.width * edgeInset.right)
        let resized = self.resizableImageWithCapInsets(inset, resizingMode: mode)
        return resized
    }
    /// 修正图片方向问题
    /// - returns: 修正后的图片
    public func fixOrientation() -> UIImage {
        let aImage = self
        // No-op if the orientation is already correct
        if aImage.imageOrientation == UIImageOrientation.Up {
            return aImage
        }
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransformIdentity
        switch aImage.imageOrientation {
        case UIImageOrientation.Down,
             UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case UIImageOrientation.Left,
             UIImageOrientation.LeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        case UIImageOrientation.Right,
             UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height)
            transform = CGAffineTransformRotate(transform, -CGFloat(M_PI_2))
        default:
            break
        }
        switch (aImage.imageOrientation) {
        case UIImageOrientation.UpMirrored,
             UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
        case UIImageOrientation.LeftMirrored,
             UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
        default:
            break
        }
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGBitmapContextCreate(nil, Int(aImage.size.width), Int(aImage.size.height),
                                        CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                        CGImageGetColorSpace(aImage.CGImage),
                                        CGImageGetBitmapInfo(aImage.CGImage).rawValue)
        CGContextConcatCTM(ctx, transform)
        switch aImage.imageOrientation {
        case UIImageOrientation.Left,
             UIImageOrientation.LeftMirrored,
             UIImageOrientation.Right,
             UIImageOrientation.RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage)
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage)
            break
        }
        // And now we just create a new UIImage from the drawing context
        if let cgimg = CGBitmapContextCreateImage(ctx) {
            return UIImage(CGImage: cgimg)
        } else {
            return aImage
        }
    }
    /// rendering mode original image
    public var originalRenderedImage: UIImage {
        get {
            if self.size.width == 0 || self.size.height == 0 {
                return self
            }
            return self.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
    }
}

// MARK: - UIScrollView

extension UIScrollView {
    /// 滚动到最底部
    /// - parameter animated: 是否需要滚动动效
    /// - note: 包括contentInset也计算在内
    public func scrollToBottom(animated: Bool) {
        self.setContentOffset(CGPointMake(self.contentOffset.x, self.contentSize.height - self.frame.size.height + self.contentInset.bottom), animated: animated)
    }
    /// 滚动到最顶部
    /// - parameter animated: 是否需要滚动动效
    /// - note: 包括contentInset也计算在内
    public func scrollToTop(animated: Bool) {
        self.setContentOffset(CGPointMake(self.contentOffset.x, -self.contentInset.top), animated: animated)
    }
    /// 是否可以纵向滚动
    /// - returns: Bool
    ///     - true: contentSize > frame
    public func canScrollVertically() -> Bool {
        return contentSize.height + contentInset.bottom > frame.size.height
    }
    /// 把某个view滚动到显示出来
    /// - parameter view:     要显示的view
    /// - parameter animated: 有没有动画效果
    /// - note: view应当是scrollView的子界面（或子界面的子界面）
    public func scrollViewToVisible(view: UIView, animated: Bool, offset: CGPoint = CGPointZero) {
        var frame = self.convertRect(view.frame, fromView: view.superview)
        frame.origin.x = frame.origin.x + offset.x
        frame.origin.y = frame.origin.y + offset.y
        self.scrollRectToVisible(frame, animated: animated)
    }
}

// MARK: - UITextField

extension UITextField {
    /// 检查文本框是否为空
    /// - parameter warn: 若为空, 是否警告(如: 显示红色闪烁)
    /// - returns: 若为空, 返回`false`. 否则返回`true`
    public func checkNotEmpty(warn: Bool = true) -> Bool {
        if text == nil || text! == "" {
            if warn {
                self.resignFirstResponder()
                self.flashRed()
            }
            return false
        } else {
            return true
        }
    }
    public func setPlaceholderLabelColorLightRed() {
        let lightRed = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.3)
        setPlaceholderLabelColor(lightRed)
    }
    public func setPlaceholderLabelColor(color: UIColor) {
        setValue(color, forKeyPath: "_placeholderLabel.textColor")
    }
    public func lengthLimit(limit: Int) {
        var text = self.text ?? ""
        let selectedRange = self.markedTextRange
        if selectedRange == nil {//没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if text.length > limit {
                text = text.substringToIndex(text.startIndex.advancedBy(limit))
                self.text = text
            }
        }
    }
    /// 注销响应
    static public func resignResponder(textFields: [UITextField]) {
        for textField in textFields {
            if textField.resignFirstResponder() {
                //                break
            }
        }
    }
    /// 检查一组文本框是否是空
    /// - parameter textFields: 文本框
    /// - returns: Bool 有任何一个为空则返回false
    /// - note: 全部都会检查到
    static public func checkTextFieldNotEmpty(textFields: UITextField!...) -> Bool {
        var array = [UITextField!]()
        for tf in textFields {
            array.append(tf)
        }
        return checkTextFieldNotEmpty(array)
    }
    static public func checkTextFieldNotEmpty(textFields: [UITextField!]) -> Bool {
        return getEmptyTextField(textFields).isEmpty
    }
    static public func getEmptyTextField(textFields: [UITextField!]) -> [UITextField!] {
        var empty = [UITextField!]()
        for tf in textFields {
            if !tf.checkNotEmpty() {
                empty.append(tf)
            }
        }
        return empty
    }
}

// MARK: - UILabel

extension UILabel {
    /// 只更新字体大小，无关字体类型
    public var fontSize: CGFloat {
        get {
            return font.pointSize
        }
        set {
            font = UIFont(name: font.familyName, size: newValue)
        }
    }
    
    /// 让label等宽
    /// - parameter labels:            labels
    /// - parameter ignorePrefixCount: 要忽略的开头的字符个数
    /// - parameter ignoreSuffixCount: 要忽略的最后的字符个数
    /// - note: 设置字符间隔，会对每一个字符生效，即，在每一个字符后边增加这个间隔，最后一个字符也会增加，如果添加背景色，就会看到末尾多了多余的空白
    /// - note: label的创建照常。font和text属性也照常设置。然后在这里会读取它们，加工到AttributedString中去。
    /// - note: 字号不必一致
    /// - note: 参数`ignoreSuffixCount`的作用如下
    /// ```
    ///   比如标题带冒号的，就应当忽略这个冒号“：”，
    ///   这样，计算的时候就不会考虑到汉字和冒号之间的间隔了。
    ///   如：
    ///     “姓名：”
    ///     “家庭住址：”
    /// ```
    /// - note: 参数`ignorePrefixCount`类似
    static public func equalWidth(labels: [UILabel], ignorePrefixCount: Int = 0, ignoreSuffixCount: Int = 0) {
        guard ignorePrefixCount >= 0 && ignoreSuffixCount >= 0 else {
            return
        }
        //title width
        let titles = labels
        var maxWidth: CGFloat = 0
        var maxCount: Int = 0
        for title in titles {
            title.sizeToFit()
            maxWidth = max(maxWidth , title.frame.size.width)
            maxCount = max(maxCount, title.text?.length ?? 0)
        }
        for title in titles {
            let spaceCount = (title.text?.length ?? 0) - 1 - ignorePrefixCount - ignoreSuffixCount
            guard spaceCount >= 0 else {
                continue
            }
            let deltaWidth = maxWidth - title.frame.size.width
            var space: CGFloat = 0
            if spaceCount != 0 {
                space = deltaWidth / CGFloat(spaceCount)
            }
            let dic = [
                NSFontAttributeName : title.font,
                NSKernAttributeName : space
            ]
            let string = title.text ?? ""
            let attrString = NSMutableAttributedString(string: string)
            let subStart = ignorePrefixCount
            let subEnd = string.length - 1 - ignoreSuffixCount
            let subLength = subEnd - subStart
            guard subLength >= 0 else {
                continue
            }
            attrString.addAttributes(dic, range: NSRange(location: subStart, length: subLength))
            title.attributedText = attrString
        }
    }
}

// MARK: - UIColor

extension UIColor {
    /// 颜色
    /// - parameter hex: 形似`#05283c`的色值
    /// - returns: UIColor
    static public func hexColor(hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var cString: String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        if cString.hasPrefix("#") {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        if cString.length != 6 {
            return UIColor.clearColor()
        }
        let rString = cString.substringWithRange(Range(cString.startIndex.advancedBy(0)..<cString.startIndex.advancedBy(2)))
        let gString = cString.substringWithRange(Range(cString.startIndex.advancedBy(2)..<cString.startIndex.advancedBy(4)))
        let bString = cString.substringWithRange(Range(cString.startIndex.advancedBy(4)..<cString.startIndex.advancedBy(6)))
        
        var r: CUnsignedInt = 0
        var g: CUnsignedInt = 0
        var b: CUnsignedInt = 0
        if NSScanner(string: rString).scanHexInt(&r)
            && NSScanner(string: gString).scanHexInt(&g)
            && NSScanner(string: bString).scanHexInt(&b) {
            return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(alpha))
        } else {
            return UIColor.clearColor()
        }
    }
    static public func rgbColor(r: Int, _ g: Int, _ b: Int, _ alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: alpha)
    }
    /// 随机颜色
    static public func randomColor() -> UIColor {
        return UIColor(red: CGFloat(arc4random() % 255)/255,
                       green: CGFloat(arc4random() % 255)/255,
                       blue: CGFloat(arc4random() % 255)/255,
                       alpha: 1)
    }
}

// MARK: - UIButton

extension UIButton {
    /// 垂直排列图标和标题
    public func layoutImageAndTitle(spacing: CGFloat, iconPos: IconPos) {
        let imageSize = self.imageView?.frame.size ?? CGSizeZero
        let titleSize = self.titleLabel?.frame.size ?? CGSizeZero
        if iconPos == .Up {
            let totalWidth = imageSize.width + titleSize.width
            self.imageEdgeInsets = UIEdgeInsetsMake(-imageSize.height/2-spacing/2, totalWidth/2-imageSize.width/2, imageSize.height/2+spacing/2, -totalWidth/2+imageSize.width/2)
            self.titleEdgeInsets = UIEdgeInsetsMake(titleSize.height/2+spacing/2, -totalWidth/2+titleSize.width/2, -titleSize.height/2-spacing/2, totalWidth/2-titleSize.width/2)
        } else if iconPos == .Down {
            let totalWidth = imageSize.width + titleSize.width
            self.imageEdgeInsets = UIEdgeInsetsMake(imageSize.height/2+spacing/2, totalWidth/2-imageSize.width/2, -imageSize.height/2-spacing/2, -totalWidth/2+imageSize.width/2)
            self.titleEdgeInsets = UIEdgeInsetsMake(-titleSize.height/2-spacing/2, -totalWidth/2+titleSize.width/2, titleSize.height/2+spacing/2, totalWidth/2-titleSize.width/2)
        } else if iconPos == .Left {
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing/2, 0, spacing/2)
            self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing/2, 0, -spacing/2)
        } else if iconPos == .Right {
            self.imageEdgeInsets = UIEdgeInsetsMake(0, titleSize.width+spacing, 0, -titleSize.width-spacing)
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width-spacing, 0, imageSize.width+spacing)
        }
    }
}

// MARK: - UIBarButtonItem

/// 一般用于：UIToolBar上，还需要自定义按钮样式的情况下
extension UIBarButtonItem {
    
    /// 生成图标+标题的UIBarButtonItem
    /// - parameter size:   按钮区域尺寸
    /// - returns: UIBarButtonItem
    /// - note: 默认图标在上，标题在下
    static public func barButtonItem(size size: CGSize, icon: UIImage? = nil, normal: UIImage? = nil, highlighted: UIImage? = nil, disabled: UIImage? = nil, title: String?, target: AnyObject?, action: Selector, iconPos: IconPos = .Left, spacing: CGFloat = 0) -> UIBarButtonItem {
        let button = UIBarButtonItem.buttonForBarButtonItem(size: size, icon: icon, normal: normal, highlighted: highlighted, disabled: disabled, title: title, target: target, action: action, iconPos: iconPos, spacing: spacing)
        let item = UIBarButtonItem(customView: button)
        return item
    }
    
    static public func buttonForBarButtonItem(size size: CGSize, icon: UIImage? = nil, normal: UIImage? = nil, highlighted: UIImage? = nil, disabled: UIImage? = nil, title: String?, target: AnyObject?, action: Selector, iconPos: IconPos = .Left, spacing: CGFloat = 0) -> UIButton {
        let button = UIButton(type: .System)
        button.setImage(icon, forState: .Normal)
        button.setBackgroundImage(normal?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        button.setBackgroundImage(highlighted?.imageWithRenderingMode(.AlwaysOriginal), forState: .Highlighted)
        button.setBackgroundImage(disabled?.imageWithRenderingMode(.AlwaysOriginal), forState: .Disabled)
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.rgbColor(83, 121, 144), forState: .Normal)
        button.setTitleColor(UIColor.rgbColor(255, 133, 153), forState: .Disabled)
        button.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        switch iconPos {
        case .Left:
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        case .Right:
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        case .Up, .Down:
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        }
        // frame
        let frame = CGRectMake(0, 0, size.width, size.height)
        button.frame = frame
        button.layoutImageAndTitle(spacing, iconPos: iconPos)
        return button
    }
    
    public var buttonTitle: String? {
        get {
            return self.button?.titleLabel?.text
        }
        set {
            self.button?.setTitle(newValue, forState: .Normal)
        }
    }
    
    public var button: UIButton? {
        get {
            return self.customView as? UIButton
        }
    }
    //--------------------------------------------------------------------------
    // MARK: - 右上角角标
    //--------------------------------------------------------------------------
    public func showDot(visible: Bool) {
        if let customView = self.customView {
            var dot = customView.viewWithTag(DOT_TAG)
            if dot == nil {
                dot = UIView(frame: CGRectMake(0, 0, 8, 8))
                dot!.layer.cornerRadius = 4
                dot!.layer.backgroundColor = UIColor.redColor().CGColor
                dot!.tag = DOT_TAG
                dot!.center.x = customView.frame.size.width
                dot!.center.y = dot!.frame.size.height/2
                customView.addSubview(dot!)
            }
            dot!.hidden = !visible
        }
    }
    private var DOT_TAG: Int { get { return 1010 }}
}

/// Icon相对Title的位置
public enum  IconPos {
    case Left//icon在左，title在右
    case Right
    case Up
    case Down
}

// MARK: - UIViewController

extension UIViewController {
    /// 启用、禁用页面交互
    public var userEnabled: Bool {
        set {
            self.view.userInteractionEnabled = newValue
        }
        get {// unused, but must have
            return self.view.userInteractionEnabled
        }
    }
}
