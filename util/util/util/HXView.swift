/****************************************************************************
 *	@desc	自定义View
 *	@date	2017/1/19
 *	@author	110102
 *	@file	HXView.swift
 *	@modify	null
 ******************************************************************************/

import Foundation

/// 渐变类型
public enum Gradient {
    case Linear//线性渐变
    case Radial//径向渐变
}

/// 四个角是否都是圆角
public enum Corner {
    case First//top left
    case Second//top right
    case Third//bottom right
    case Fourth//bottom left
}

public class GradientView: UIView {
    private var lineColor: UIColor = UIColor.clearColor()
    private var color1: UIColor = UIColor.clearColor()
    private var color2: UIColor = UIColor.clearColor()
    private var point1: CGPoint = CGPointZero
    private var point2: CGPoint = CGPointZero
    private var cornerRadius: CGFloat = 0
    private var borderWidth: CGFloat = 0
    private var components: [CGFloat] = []
    private var type: Gradient = Gradient.Linear
    
    override public func drawRect(rect: CGRect) {
        // border
        var radius = cornerRadius
        radius = min(radius, rect.size.width/2)
        radius = min(radius, rect.size.height/2)
        let context = UIGraphicsGetCurrentContext()
        // mask
        roundCorner(context, size: rect.size, radius: radius, borderWidth: borderWidth/2)//shrink a little
        CGContextSaveGState(context)
        CGContextClip(context)
        // gradient
        let space = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColorComponents(space, self.components, nil, 2)
        let gradientContext = UIGraphicsGetCurrentContext()
        let p1 = point1.pointFromSize(rect.size)
        let p2 = point2.pointFromSize(rect.size)
        switch type {
        case Gradient.Radial:
            let gradientRadius = p1.distance(p2)
            let centerPoint = p1
            CGContextDrawRadialGradient(gradientContext, gradient, centerPoint, 0, centerPoint, gradientRadius, CGGradientDrawingOptions.DrawsAfterEndLocation)
        case Gradient.Linear:
            CGContextDrawLinearGradient(gradientContext, gradient, p1, p2, CGGradientDrawingOptions.DrawsAfterEndLocation)
        }
        CGContextRestoreGState(context)
        roundCorner(context, size: rect.size, radius: radius, borderWidth: borderWidth)
        CGContextSetLineWidth(context, borderWidth)
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
    }
    /// init
    /// - parameter size:         尺寸（若是之后变动，这个值也就无用了）
    /// - parameter lineColor:    线色
    /// - parameter color1:       渐变色一
    /// - parameter color2:       渐变色二
    /// - parameter point1:       渐变起点（在Size中的比例，不是绝对值）
    /// - parameter point2:       渐变终点（在Size中的比例，不是绝对值）
    /// - parameter cornerRadius: 圆角半径
    /// - parameter borderWidth:  线宽
    /// - parameter type:         渐变类型：线性、径向
    /// - returns: UIView
    public init(size: CGSize = CGSizeZero, lineColor: UIColor? = nil, color1: UIColor, color2: UIColor, point1: CGPoint, point2: CGPoint, cornerRadius: CGFloat, borderWidth: CGFloat, type: Gradient) {
        super.init(frame: CGRectMake(0, 0, size.width, size.height))
        self.lineColor = lineColor ?? UIColor.clearColor()
        self.color1 = color1
        self.color2 = color2
        self.point1 = point1
        self.point2 = point2
        self.cornerRadius = cornerRadius
        self.borderWidth = (lineColor == nil) ? 0 : borderWidth
        self.type = type
        // color components(rgba,rgba,...)
        let colors = [color1, color2]
        for i in 0..<colors.count {
            let colorRef: CGColorRef = colors[i].CGColor
            let tempComponents = CGColorGetComponents(colorRef)
            for j in 0..<4 {
                components.append(tempComponents[j])
            }
        }
        self.backgroundColor = UIColor.clearColor()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public class RoundCornerView: UIView {
    public var cornerRadius: CGFloat = 0 {
        didSet {
            update()
        }
    }
    public var lineColor: UIColor = UIColor.clearColor() {
        didSet {
            update()
        }
    }
    public var fillColor: UIColor = UIColor.clearColor() {
        didSet {
            update()
        }
    }
    private var borderWidth: CGFloat = 0
    private var cornerSet: Set<Corner> = Set()
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        var radius = cornerRadius
        radius = min(radius, rect.size.width/2)
        radius = min(radius, rect.size.height/2)
        roundCorner(context, size: rect.size, radius: radius, borderWidth: borderWidth, corner: cornerSet)
        CGContextSetLineWidth(context, borderWidth)
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
        CGContextSetFillColorWithColor(context, fillColor.CGColor)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
    }
    
    public init(size: CGSize = CGSizeZero, lineColor: UIColor?, fillColor: UIColor?, cornerRadius: CGFloat, borderWidth: CGFloat, corner: Set<Corner> = Set(arrayLiteral: .First, .Second, .Third, .Fourth)) {
        super.init(frame: CGRectMake(0, 0, size.width, size.height))
        self.lineColor = lineColor ?? UIColor.clearColor()
        self.fillColor = fillColor ?? UIColor.clearColor()
        self.cornerRadius = cornerRadius
        self.borderWidth = (lineColor == nil) ? 0 : borderWidth
        self.backgroundColor = UIColor.clearColor()
        self.userInteractionEnabled = false
        self.cornerSet = corner
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func update() {
        setNeedsDisplay()
    }
}

public class CircleView: UIView {
    private var lineColor: UIColor = UIColor.clearColor()
    private var fillColor: UIColor = UIColor.clearColor()
    private var borderWidth: CGFloat = 0
    
    override public func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let radius = rect.size.width/2
        roundCircle(context, radius: radius, borderWidth: borderWidth)
        CGContextSetLineWidth(context, borderWidth)
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
        CGContextSetFillColorWithColor(context, fillColor.CGColor)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
    }
    
    /// 画圆
    /// - parameter radius:      半径
    /// - parameter lineColor:   线颜色
    /// - parameter fillColor:   填充颜色
    /// - parameter borderWidth: 线宽
    /// - returns: UIView
    /// - note: 如果设置线宽，会有一部分被边界裁切掉，所以在绘制的时候，根据线宽，缩小了半径值，使得整个圆都在rect内部。
    public init(radius: CGFloat, lineColor: UIColor?, fillColor: UIColor?, borderWidth: CGFloat) {
        super.init(frame: CGRectMake(0, 0, radius*2, radius*2))
        self.lineColor = lineColor ?? UIColor.clearColor()
        self.fillColor = fillColor ?? UIColor.clearColor()
        self.borderWidth = borderWidth
        self.backgroundColor = UIColor.clearColor()
        self.userInteractionEnabled = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

/// 包含在set内的，就是要绘制圆角。默认全部包含。
private func roundCorner(context: CGContextRef?, size: CGSize, radius: CGFloat, borderWidth: CGFloat, corner: Set<Corner> = Set(arrayLiteral: .First, .Second, .Third, .Fourth)) {
    let width = size.width
    let height = size.height
    let margin = borderWidth/2
    let radius = radius - margin
    if corner.contains(.First) {
        CGContextMoveToPoint(context, 0+margin, radius+margin)//start, top-left-left
        CGContextAddArcToPoint(context, 0+margin, 0+margin, radius+margin, 0+margin, radius)//top-left-top
    } else {
        CGContextMoveToPoint(context, 0+margin, 0+margin)//start, top-left
    }
    if corner.contains(.Second) {
        CGContextAddLineToPoint(context, width-margin-radius, 0+margin)//top-right-top
        CGContextAddArcToPoint(context, width-margin, 0+margin, width-margin, radius+margin, radius)//top-right-right
    } else {
        CGContextAddLineToPoint(context, width-margin, 0+margin)//top-right
    }
    if corner.contains(.Third) {
        CGContextAddLineToPoint(context, width-margin, height-margin-radius)//bottom-right-right
        CGContextAddArcToPoint(context, width-margin, height-margin, width-margin-radius, height-margin, radius)//bottom-right-bottom
    } else {
        CGContextAddLineToPoint(context, width-margin, height-margin)//bottom-right
    }
    if corner.contains(.Fourth) {
        CGContextAddLineToPoint(context, radius+margin, height-margin)//bottom-left-bottom
        CGContextAddArcToPoint(context, 0+margin, height-margin, 0+margin, height-margin-radius, radius)//bottom-left-left
    } else {
        CGContextAddLineToPoint(context, margin, height-margin)//bottom-left
    }
    if corner.contains(.First) {
        CGContextAddLineToPoint(context, 0+margin, radius+margin)//end, top-left-left
    } else {
        CGContextAddLineToPoint(context, 0+margin, margin)//end, top-left
    }
    CGContextClosePath(context)
}

private func roundCircle(context: CGContextRef?, radius: CGFloat, borderWidth: CGFloat) {
    let margin = borderWidth/2
    CGContextAddArc(context, radius, radius, radius-margin, 0, CGFloat(M_PI*2), 1)
}

