/****************************************************************************
 *	@desc	Extension+Swift
 *	@date	2017/1/19
 *	@author	110102
 *	@file	Extension+Swift.swift
 *	@modify	null
 ******************************************************************************/

import Foundation

// MARK: - String

extension String {
    /**
    /// 字符串的MD5值
    /// - note: MD5值是小写的
    public var md5String: String {
        get {
            let cstr = (self as NSString).UTF8String
            let buffer = UnsafeMutablePointer<UInt8>.alloc(16)
            CC_MD5(cstr, CC_LONG(strlen(cstr)), buffer)
            let md5String = NSMutableString(capacity: 16)
            for i in 0...15 {
                md5String.appendFormat("%02x", buffer[i])
            }
            free(buffer)
            return md5String as String
        }
    }
    /// MD5值是大写的
    public var MD5String: String {
        get {
            return self.md5String.uppercaseString
        }
    }
     */
    /// 本地化字符串
    public var localizedString: String {
        get {
            return NSLocalizedString(self, comment: "")
        }
    }
    /// 长度
    public var length: Int {
        get {
            return (self as NSString).length
        }
    }
    /// 以星号替代部分字符，字符串是Email形式
    public var truncateEmail: String {
        get {
            let substring = self.componentsSeparatedByString("@")
            if substring.count < 2 {
                return ""
            }
            var result = substring[0].truncateTail
            for i in 1..<substring.count {
                result += "@"
                result += substring[i]
            }
            return result
        }
    }
    /// 以星号替代部分字符
    public var truncateTail: String {
        get {
            var result: String = ""
            let string = self
            let length = string.length
            let maxNumOfStar = 3
            let suffixLength = min(length/2, maxNumOfStar)
            let preLength = min(length - suffixLength, maxNumOfStar)
            var stars = ""
            for _ in 0..<suffixLength {
                stars.appendContentsOf("*")
            }
            let preString = string.substringToIndex(string.startIndex.advancedBy(preLength))
            result = preString + stars
            return result
        }
    }
    /// 设置行高的字符串
    public func withLineSpacing(lineSpacing: CGFloat) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.lineSpacing(lineSpacing)
        return attributedString
    }
    
    public func getAttributeString(lineSpacing: CGFloat, align: NSTextAlignment?, color: UIColor?) -> NSMutableAttributedString {
        let text = NSMutableAttributedString(string: self)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = lineSpacing
        if align != nil {
            paragraph.alignment = align!
        }
        text.addAttributes([NSParagraphStyleAttributeName : paragraph], range: NSRange(0..<text.length))
        if color != nil {
            text.addAttributes([NSForegroundColorAttributeName : color!], range: NSRange(0..<text.length))
        }
        return text
    }
    /// 字符串占据的尺寸
    /// - parameter font:    该字符串所用的字体(字体大小不一样,显示出来的面积也不同)
    /// - parameter maxSize: 为限制改字体的最大宽和高
    ///     - 如果显示一行,则宽高都设置为MAXFLOAT
    ///     - 如果显示多行,只需将宽设置一个有限定长值,高设置为MAXFLOAT
    /// - returns: 返回值是该字符串所占的大小(width, height)
    public func sizeWithFont(font: UIFont, maxSize: CGSize = CGSizeMake(CGFloat.max, CGFloat.max)) -> CGSize {
        let attrs = [NSFontAttributeName : font]
        return (self as NSString).boundingRectWithSize(maxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrs, context: nil).size
    }
    /// 将参数拼接形式的字符串转为字典，通常是url链接的“?”之后部分的文字
    /// - note: 参数的拼接不要嵌套
    public func getParameters() -> [String : AnyObject] {
        let delimiterSet = NSCharacterSet(charactersInString: "&;")
        var pairs: [String : AnyObject] = [:]
        let query = self
        let scanner = NSScanner(string: query)
        while (!scanner.atEnd) {
            var pairString: NSString? = ""
            scanner.scanUpToCharactersFromSet(delimiterSet, intoString: &pairString)
            scanner.scanCharactersFromSet(delimiterSet, intoString: nil)
            var kvPair = pairString?.componentsSeparatedByString("=")
            if kvPair?.count == 2 {
                let key = kvPair?[0].stringByRemovingPercentEncoding ?? ""
                let value = kvPair?[1].stringByRemovingPercentEncoding
                pairs[key] = value
            }
        }
        return pairs
    }
    /// 通常在输入金额的时候，对文本进行限制，成为一个合法的金额字符串
    /// - note: 前提条件是，字符串本身是合法的数值
    public var money: String {
        get {
            var text = self
            if text == "." {
                text = "0."
            } else {
                let array = text.componentsSeparatedByString(".")
                if array.count >= 2 {
                    let str1 = array[0]
                    var str2 = array[1]
                    str2 = str2.substringToIndex(str2.startIndex.advancedBy(2, limit: str2.endIndex))
                    text = "\(str1).\(str2)"
                }
            }
            return text
        }
    }
}

// MARK: - NSMutableAttributedString

extension NSMutableAttributedString {
    public func align(align: NSTextAlignment) -> NSMutableAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = align
        self.addAttributes([NSParagraphStyleAttributeName : style], range: NSRange(0..<self.length))
        return self
    }
    
    public func lineSpacing(lineSpacing: CGFloat) -> NSMutableAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        self.addAttributes([NSParagraphStyleAttributeName : style], range: NSRange(0..<self.length))
        return self
    }
    
    public func color(color: UIColor) -> NSMutableAttributedString {
        self.addAttributes([NSForegroundColorAttributeName : color], range: NSRange(0..<self.length))
        return self
    }
}

// MARK: - Double

extension Double {
    /// 获得金额的数值，避免`0.01`变成`0.00999`的情况
    public var moneyValue: Double {
        get {
            let valueString = String(format: "%.2f", self)
            return Double(valueString) ?? 0.0
        }
    }
}

// MARK: - CGPoint

extension CGPoint {
    /// 偏移
    /// - parameter x: x
    /// - parameter y: y
    /// - returns: CGPoint
    public func offset(x: CGFloat, _ y: CGFloat) -> CGPoint {
        return CGPointMake(self.x + x, self.y + y)
    }
    /// x偏移
    public func offsetX(x: CGFloat) -> CGPoint {
        return self.offset(x, 0)
    }
    /// y偏移
    public func offsetY(y: CGFloat) -> CGPoint {
        return self.offset(0, y)
    }
    /// point在size中的比例转换
    public func persentInSize(size: CGSize) -> CGPoint {
        var p = CGPointZero
        if size.width > 0 {
            p.x = self.x / size.width
        }
        if size.height > 0 {
            p.y = self.y / size.height
        }
        return p
    }
    /// 乘法
    public func multiple(num: CGFloat) -> CGPoint {
        return CGPointMake(x * num, y * num)
    }
    /// 除法
    public func div(num: CGFloat) -> CGPoint {
        if num == 0 {
            return self
        } else {
            return multiple(1/num)
        }
    }
    /// 比例的点在Size中的定位
    func pointFromSize(size: CGSize) -> CGPoint {
        return CGPointMake(x * size.width, y * size.height)
    }
    /// 距离
    public func distance(point: CGPoint) -> CGFloat {
        return sqrt(pow(self.x - point.x, 2) + pow(self.y - point.y, 2))
    }
}

// MARK: - NSObject

extension NSObject {
    public func setObject(object: AnyObject, forKey key: String) {
        objc_setAssociatedObject(self, key, object, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    public func getObjectForKey(key: String) -> AnyObject {
        return objc_getAssociatedObject(self, key)
    }
}


