//
//  KeenUtils.swift
//  KeenDialog
//
//  Created by chongzone on 2021/1/27.
//

import UIKit

extension NSObject {
    
    /// 类名
    public var className: String {
        let name = type(of: self).description()
        if name.contains(".") {
            return name.components(separatedBy: ".").last!
        }else {
            return name
        }
    }
    
    /// 类名
    public static var className: String {
        return String(describing: self)
    }
}

extension String {
    
    /// 计算字符串宽高
    /// - Parameters:
    ///   - font: 字体
    ///   - width: 设定的宽度
    ///   - height: 设定的高度
    ///   - kernSpace: 字符间距
    ///   - lineSpace: 行间距
    /// - Returns: CGSize 值
    public func calculateSize(
        font: UIFont,
        width: CGFloat = CGFloat.greatestFiniteMagnitude,
        height: CGFloat = CGFloat.greatestFiniteMagnitude,
        kernSpace: CGFloat = 0,
        lineSpace: CGFloat = 0
    ) -> CGSize {
        if kernSpace == 0, lineSpace == 0 {
            let rect = self.boundingRect(
                with: CGSize(width: width, height: height),
                options: .usesLineFragmentOrigin,
                attributes: [.font: font],
                context: nil
            )
            return CGSize(width: ceil(rect.width), height: ceil(rect.height))
        }else {
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            let label = UILabel(frame: rect).font(font).text(self).numberOfLines(0)
            let style = NSMutableParagraphStyle()
            style.lineSpacing = lineSpace
            let attr = NSMutableAttributedString(
                string: self,
                attributes: [.kern : kernSpace]
            )
            attr.addAttribute(
                .paragraphStyle,
                value: style,
                range: NSMakeRange(0, self.count)
            )
            label.attributedText = attr
            return label.sizeThatFits(rect.size)
        }
    }
}

extension Collection {
    
    /// 取出指定索引值 越界处理
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array  {
    
    /// 添加元素
    /// - Parameter elements: 新元素数组
    public mutating func append(_ elements: [Element]) {
        elements.forEach{ self.append($0) }
    }
}

extension Dictionary {
    
    /// 是否为空
    public var isEmpty: Bool { keys.count == 0 }
    
    /// 是否包含某个 key
    public func contains(_ key: Key) -> Bool { index(forKey: key) != nil }
    
    /// 键值 key 的读写
    public subscript<T>(key: Key) -> T? {
        get {
            return self[key] as? T
        }
        set {
            self[key] = newValue as? Value
        }
    }
    
    /// 根据 keys 集合取对应的 values 集合
    public subscript<Keys: Sequence>(keys: Keys) -> [Value] where Keys.Iterator.Element == Key {
        var values: [Value] = []
        keys.forEach { key in
            if let value = self[key] {
                values.append(value)
            }
        }
        return values
    }
}

extension UIColor {
    
    /// 改变透明度 不会影响子视图透明度
    /// - Parameter alpha: 透明度
    /// - Returns: 对应的 Color
    public func toColor(of alpha: CGFloat) -> UIColor {
        return withAlphaComponent(alpha)
    }
    
    /// 由 Hex 生成 Color 透明度默认 1.0
    /// - Parameters:
    ///   - hexString: 十六进制字符串
    ///   - alpha: 透明度
    /// - Returns: 对应的 Color
    public static func color(hexString: String, alpha: CGFloat = 1.0) -> UIColor {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if hex.hasPrefix("#") {
            hex = "\(hex.dropFirst())"
        }
        if hex.hasPrefix("0x") {
            hex = "\(hexString.dropFirst(2))"
        }
        var hexValue: UInt64 = 0
        let scanner: Scanner = Scanner(string: hex)
        scanner.scanHexInt64(&hexValue)
        return UIColor(
            red: CGFloat(Int(hexValue >> 16) & 0x0000FF) / 255.0,
            green: CGFloat(Int(hexValue >> 8) & 0x0000FF) / 255.0,
            blue: CGFloat(Int(hexValue) & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension CGFloat {
    
    /// 屏幕宽度
    public static var screenWidth: CGFloat { UIScreen.main.bounds.size.width }
    /// 屏幕高度
    public static var screenHeight: CGFloat { UIScreen.main.bounds.size.height }
    /// 安全区域顶部高度
    public static var safeAreaTopHeight: CGFloat { UIDevice.isIPhoneXSeries ? 24.0:0.0 }
    /// 安全区域底部高度
    public static var safeAreaBottomHeight: CGFloat { UIDevice.isIPhoneXSeries ? 34.0:0.0 }
}

extension UIDevice {
    
    /// windows
    public static var windows: [UIWindow] { UIApplication.shared.windows }
    
    /// 主屏幕
    public static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .first { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .map { $0?.windows.first } ?? UIApplication.shared.delegate?.window ?? nil
        }
        return UIApplication.shared.delegate?.window ?? nil
    }
    
    /// 是否 X 系列机型
    public static var isIPhoneXSeries: Bool {
        var iPhoneXSeries = false
        guard UIDevice.current.userInterfaceIdiom == .phone else { return iPhoneXSeries }
        if #available(iOS 11.0, *) {
            if let w = keyWindow {
                if w.safeAreaInsets.bottom > 0.0  {
                    iPhoneXSeries = true
                }
            }
        }
        return iPhoneXSeries
    }
}

extension UIView {
    
    /// 初始化
    public convenience init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: width, height: height))
    }
}

extension UIView {

    public var x: CGFloat {
        get {
            return frame.origin.x
        } set(value) {
            frame = CGRect(x: value, y: y, width: width, height: height)
        }
    }

    public var y: CGFloat {
        get {
            return frame.origin.y
        } set(value) {
            frame = CGRect(x: x, y: value, width: width, height: height)
        }
    }

    public var width: CGFloat {
        get {
            return frame.size.width
        } set(value) {
            frame = CGRect(x: x, y: y, width: value, height: height)
        }
    }

    public var height: CGFloat {
        get {
            return frame.size.height
        } set(value) {
            frame = CGRect(x: x, y: y, width: width, height: value)
        }
    }

    public var origin: CGPoint {
        get {
            return frame.origin
        } set(value) {
            frame = CGRect(origin: value, size: frame.size)
        }
    }

    public var size: CGSize {
        get {
            return frame.size
        } set(value) {
            frame = CGRect(origin: frame.origin, size: value)
        }
    }

    public var centerX: CGFloat {
        get {
            return center.x
        } set(value) {
            center = CGPoint(x: value, y: centerY)
        }
    }

    public var centerY: CGFloat {
        get {
            return center.y
        } set(value) {
            center = CGPoint(x: centerX, y: value)
        }
    }

    public var top: CGFloat {
        get {
            return y
        } set(value) {
            y = value
        }
    }

    public var left: CGFloat {
        get {
            return x
        } set(value) {
            x = value
        }
    }

    public var bottom: CGFloat {
        get {
            return y + height
        } set(value) {
            y = value - height
        }
    }

    public var right: CGFloat {
        get {
            return x + width
        } set(value) {
            x = value - width
        }
    }
}

extension UIView {
    
    /// frame
    /// - Parameter frame: frame
    /// - Returns: 自身
    @discardableResult
    public func frame(_ frame: CGRect) -> Self {
        self.frame = frame
        return self
    }
    
    /// 背景色
    /// - Parameter color: 颜色
    /// - Returns: 自身
    @discardableResult
    public func backColor(_ color: UIColor?) -> Self {
        backgroundColor = color
        return self
    }
    
    /// tag 值
    /// - Parameter tag: tag 值
    /// - Returns: 自身
    @discardableResult
    public func tag(_ tag: Int) -> Self {
        self.tag = tag
        return self
    }
    
    /// 是否支持响应 label & imageView 默认 false
    /// - Parameter enabled: 是否支持响应
    /// - Returns: 自身
    @discardableResult
    public func isUserInteractionEnabled(_ enabled: Bool) -> Self {
        isUserInteractionEnabled = enabled
        return self
    }
    
    /// 显示模式
    /// - Parameter mode: 模式类型
    /// - Returns: 自身
    @discardableResult
    public func contentMode(_ mode: UIView.ContentMode) -> Self {
        contentMode = mode
        return self
    }
    
    /// 是否超出的裁剪 默认 true
    /// - Parameter isClips: 是否裁剪
    /// - Returns: 自身
    @discardableResult
    public func clipsToBounds(_ isClips: Bool = true) -> Self {
        clipsToBounds = isClips
        return self
    }
    
    /// 添加到父视图
    /// - Parameter superView: 父视图
    /// - Returns: 自身
    @discardableResult
    public func addViewTo(_ superView: UIView) -> Self {
        superView.addSubview(self)
        return self
    }
}

extension UIView {
    
    /// View 圆角  默认 View 四周皆有圆角
    /// - Parameters:
    ///   - size: View 宽高
    ///   - radius: 圆角大小
    ///   - corner: 圆角位置
    public func viewCorner(
        size: CGSize,
        radius: CGFloat,
        corner: UIRectCorner = .allCorners
    ) {
        let path = UIBezierPath(
            roundedRect: CGRect(origin: .zero, size: size),
            byRoundingCorners: corner,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(origin: .zero, size: size)
        shapeLayer.path = path.cgPath
        layer.mask = shapeLayer
    }
}

extension Bundle {
    
    /// 获取当前 bundle 资源
    /// - Parameters:
    ///   - aClass: 资源库类
    ///   - bundle: 当前 bundle 名称
    ///   - name: 资源名称
    ///   - ext: 资源后缀  默认 plist
    /// - Returns: 资源
    public static func fileResouce(of aClass: AnyClass, bundle: String, name: String, ofType ext: String = "plist") -> [Any] {
        let mainBundle = Bundle(for: aClass)
        let bundlePath = mainBundle.path(forResource: bundle, ofType: "bundle")!
        let fileName = String(format: "%@.%@", name, ext)
        let arrs = NSArray(contentsOfFile: bundlePath + "/" + fileName)
        return arrs as! [Any]
    }
}

extension CALayer {
    
    /// frame
    /// - Parameter frame: frame
    /// - Returns: 自身
    @discardableResult
    public func frame(_ frame: CGRect) -> Self {
        self.frame = frame
        return self
    }
    
    /// 添加到父视图层
    /// - Parameter superLayer: 父视图层
    /// - Returns: 自身
    @discardableResult
    public func addLayerTo(_ superLayer: CALayer) -> Self {
        superLayer.addSublayer(self)
        return self
    }
}

extension CALayer {
    
    /// 基础动画配置
    /// - Parameters:
    ///   - keyPath: 动画类型
    ///   - fromValue: 开始值
    ///   - toValue: 结束值
    ///   - duration: 动画持续时间 单位 s
    ///   - delay: 延迟时间 单位 s
    ///   - repeatCount: 动画重复次数
    ///   - fillMode: 动画填充模式 默认 forwards
    ///   - autoreverses: 动画结束是否自动反向运动 默认 false
    ///   - isCumulative: 是否累计动画 默认 false
    ///   - removedOnCompletion: 结束后是否回到原状态 默认 false
    ///   - option: 动画的控制方式
    ///   - animationKey: 控制动画执行对应的key
    public func basicAnimationKeyPath(
        keyPath: String,
        fromValue: Any?,
        toValue: Any?,
        duration: TimeInterval = 2.0,
        delay: TimeInterval = 0,
        repeatCount: Float = 1,
        fillMode: CAMediaTimingFillMode = .forwards,
        autoreverses: Bool = false,
        isCumulative: Bool = false,
        removedOnCompletion: Bool = false,
        option: CAMediaTimingFunctionName = .default,
        animationKey: String?
    ) {
        let animation: CABasicAnimation = CABasicAnimation()
        animation.beginTime = delay + self.convertTime(CACurrentMediaTime(), to: nil)
        
        if let fValue = fromValue { animation.fromValue = fValue }
        if let tValue = toValue { animation.toValue = tValue }
        
        animation.keyPath = keyPath
        animation.duration = duration
        animation.fillMode = fillMode
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses
        
        animation.isCumulative = isCumulative
        animation.isRemovedOnCompletion = removedOnCompletion
        animation.timingFunction = CAMediaTimingFunction(name: option)
        add(animation, forKey: animationKey)
    }
}

extension CAShapeLayer {
 
    /// 设置路径 决定了其形状
    /// - Parameters:
    ///   - path: 路径
    /// - Returns: 自身
    @discardableResult
    public func path(_ path: CGPath) -> Self {
        self.path = path
        return self
    }
    
    /// 填充色
    /// - Parameters:
    ///   - color: 填充色
    /// - Returns: 自身
    @discardableResult
    public func fillColor(_ color: UIColor) -> Self {
        fillColor = color.cgColor
        return self
    }
    
    /// 线条颜色
    /// - Parameters:
    ///   - color: 线条颜色
    /// - Returns: 自身
    @discardableResult
    public func strokeColor(_ color: UIColor) -> Self {
        strokeColor = color.cgColor
        return self
    }
    
    /// 路径起点的相对位置 0-1 默认 0
    /// - Parameters:
    ///   - start: 开始位置
    /// - Returns: 自身
    @discardableResult
    public func strokeStart(_ start: CGFloat) -> Self {
        strokeStart = start
        return self
    }
    
    /// 路径终点的相对位置 0-1 默认 1
    /// - Parameters:
    ///   - end: 结束位置
    /// - Returns: 自身
    @discardableResult
    public func strokeEnd(_ end: CGFloat) -> Self {
        strokeEnd = end
        return self
    }
    
    /// 设置线宽
    /// - Parameters:
    ///   - width: 线宽
    /// - Returns: 自身
    @discardableResult
    public func lineWidth(_ width: CGFloat) -> Self {
        lineWidth = width
        return self
    }
    
    /// path 终点样式 butt(无样式) round(圆形) square(方形)
    /// - Parameters:
    ///   - cap: 终点样式
    /// - Returns: 自身
    @discardableResult
    public func lineCap(_ cap: CAShapeLayerLineCap) -> Self {
        lineCap = cap
        return self
    }
    
    /// 路径连接部分的拐角样式 miter(尖状) round(圆形) bevel(平形)
    /// - Parameters:
    ///   - join: 拐角样式
    /// - Returns: 自身
    @discardableResult
    public func lineJoin(_ join: CAShapeLayerLineJoin) -> Self {
        lineJoin = join
        return self
    }
}

extension Date {
    
    /// 对应的年份(∞)
    public var dateYear: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    /// 对应的月份(1 - 12)
    public var dateMonth: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    /// 对应月份的几号(1 - 31)
    public var dateDay: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    /// 对应的小时数(0 - 24)
    public var dateHour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    /// 对应的分钟数(0 - 60)
    public var dateMinute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    /// 转特定格式的日期 默认格式 yyyy-MM-dd HH:mm:ss
    /// - Parameters:
    ///   - date: 日期
    ///   - format: 转换格式
    /// - Returns: 转换后的日期
    public static func date(of date: Date, format: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh-CN")
        formatter.dateFormat = format
        let dateStr = formatter.string(from: date)
        guard let date = formatter.date(from: dateStr) else {
            #if DEBUG
            fatalError("format 格式错误")
            #else
            return Date()
            #endif
        }
        return date
    }
    
    /// Date 转时间字符串 默认格式 yyyy-MM-dd HH:mm:ss
    /// - Parameters:
    ///   - date: 日期
    ///   - format: 转换格式
    /// - Returns: 转换后的字符串
    public static func dateToString(_ date: Date, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh-CN")
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    /// 时间字符串转 Date 默认格式 yyyy-MM-dd HH:mm:ss
    /// - Parameters:
    ///   - aString: 时间字符串
    ///   - format: 转换格式
    /// - Returns: 转换后的字符串
    public static func stringToDate(_ aString: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = format
        guard let date = formatter.date(from: aString) else {
            #if DEBUG
            fatalError("format 格式错误")
            #else
            return Date()
            #endif
        }
        return date
    }
}

extension UILabel {
    
    /// 文本
    /// - Parameters:
    ///   - text: 文本
    /// - Returns: 自身
    @discardableResult
    public func text(_ text: String?) -> Self {
        self.text = text
        return self
    }
    
    /// 文本字体
    /// - Parameter font: 字体
    /// - Returns: 自身
    @discardableResult
    public func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
    
    /// 文本颜色
    /// - Parameter color: 颜色
    /// - Returns:  自身
    @discardableResult
    public func textColor(_ color: UIColor) -> Self {
        textColor = color
        return self
    }
    
    /// 行数 默认 1 行
    /// - Parameter number: 行数
    /// - Returns: 自身
    @discardableResult
    public func numberOfLines(_ number: Int = 1) -> Self {
        numberOfLines = number
        return self
    }
    
    /// 截取模式 默认 byTruncatingTail
    /// - Parameter mode: 模式
    /// 1. byWordWrapping(按词拆分) | byCharWrapping(按字符拆分) | byClipping(将多余的部分截断)
    /// 2. byTruncatingHead(省略头部文字) | byTruncatingTail(省略尾部文字) | byTruncatingMiddle(省略中间部分文字)
    /// - Returns: 自身
    @discardableResult
    public func lineMode(_ mode: NSLineBreakMode = .byTruncatingTail) -> Self {
        lineBreakMode = mode
        return self
    }
    
    /// 对齐方式
    /// - Parameter alignment: 对齐方式 默认靠左
    /// - Returns: 自身
    @discardableResult
    public func alignment(_ alignment: NSTextAlignment = .left) -> Self {
        textAlignment = alignment
        return self
    }
}

extension UITextView {
    
    /// 文本
    /// - Parameters:
    ///   - text: 文本
    /// - Returns: 自身
    @discardableResult
    public func text(_ text: String) -> Self {
        self.text = text
        return self
    }
    
    /// 字体
    /// - Parameter font: 字体
    /// - Returns: 自身
    @discardableResult
    public func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
    
    /// 文本颜色
    /// - Parameter color: 颜色
    /// - Returns: 自身
    @discardableResult
    public func textColor(_ color: UIColor) -> Self {
        textColor = color
        return self
    }
    
    /// 对齐方式 默认靠左
    /// - Parameter alignment: 对齐方式
    /// - Returns: 自身
    @discardableResult
    public func alignment(_ alignment: NSTextAlignment = .left) -> Self {
        textAlignment = alignment
        return self
    }
    
    /// 是否可编辑
    /// - Parameter able: 是否可编辑
    /// - Returns: 自身
    @discardableResult
    public func isEditable(_ able: Bool) -> Self {
        isEditable = able
        return self
    }
    
    /// 是否可被选
    /// - Parameter able: 是否可被选
    /// - Returns: 自身
    @discardableResult
    public func isSelectable(_ able: Bool) -> Self {
        isSelectable = able
        return self
    }
    
    /// 内边距
    /// - Parameter edge: 内边距
    /// - Returns: 自身
    @discardableResult
    public func textInset(_ edge: UIEdgeInsets) -> Self {
        textContainerInset = edge
        textContainer.lineFragmentPadding = edge.left
        return self
    }
}

extension UIControl {
    
    /// 内容水平对齐方式
    /// - Parameter horizontalAlignment: 对齐方式
    /// - Returns: 自身
    @discardableResult
    public func horizontalAlignment(_ horizontalAlignment: UIControl.ContentHorizontalAlignment) -> Self {
        contentHorizontalAlignment = horizontalAlignment
        return self
    }
}

extension UIButton {
    
    /// 按钮文字 状态默认 normal
    /// - Parameters:
    ///   - title: 文案
    ///   - state: 状态
    /// - Returns: 自身
    @discardableResult
    public func title(_ title: String?, _ state: UIControl.State = .normal) -> Self {
        setTitle(title, for: state)
        return self
    }
    
    /// 按钮文字
    /// - Parameters:
    ///   - title: 文案
    ///   - state1: 状态 1
    ///   - state2: 状态 2
    /// - Returns: 自身
    @discardableResult
    public func title(_ title: String?, _ state1: UIControl.State, _ state2: UIControl.State) -> Self {
        setTitle(title, for: state1)
        setTitle(title, for: state2)
        return self
    }
    
    /// 按钮字体
    /// - Parameter font: 字体
    /// - Returns: 自身
    @discardableResult
    public func font(_ font: UIFont) -> Self {
        titleLabel?.font = font
        return self
    }
    
    /// 按钮文字颜色 状态默认 normal
    /// - Parameters:
    ///   - color: 文案颜色
    ///   - state: 状态
    /// - Returns: 自身
    @discardableResult
    public func titleColor(_ color: UIColor, _ state: UIControl.State = .normal) -> Self {
        setTitleColor(color, for: state)
        return self
    }
    
    /// 按钮文字颜色
    /// - Parameters:
    ///   - color: 文案颜色
    ///   - state1: 状态 1
    ///   - state2: 状态 2
    /// - Returns: 自身
    @discardableResult
    public func titleColor(_ color: UIColor, _ state1: UIControl.State, _ state2: UIControl.State) -> Self {
        setTitleColor(color, for: state1)
        setTitleColor(color, for: state2)
        return self
    }
    
    /// 按钮图片 状态默认 normal
    /// - Parameters:
    ///   - image: 图片
    ///   - state: 状态
    /// - Returns: 自身
    @discardableResult
    public func image(_ image: UIImage?, _ state: UIControl.State = .normal) -> Self {
        setImage(image, for: state)
        return self
    }
    
    /// 按钮图片
    /// - Parameters:
    ///   - image: 图片
    ///   - state1: 状态 1
    ///   - state2: 状态 2
    /// - Returns: 自身
    @discardableResult
    public func image(_ image: UIImage?, _ state1: UIControl.State, _ state2: UIControl.State) -> Self {
        setImage(image, for: state1)
        setImage(image, for: state2)
        return self
    }
    
    /// 按钮背景色 状态默认 normal
    /// - Parameters:
    ///   - color: 背景色
    ///   - state: 状态
    /// - Returns: 自身
    @discardableResult
    public func backColor(_ color: UIColor, _ state: UIControl.State = .normal) -> Self {
        setBackgroundImage(UIImage.image(color: color), for: state)
        return self
    }
    
    /// 按钮背景色
    /// - Parameters:
    ///   - color: 背景色
    ///   - state1: 状态 1
    ///   - state2: 状态 2
    /// - Returns: 自身
    @discardableResult
    public func backColor(_ color: UIColor, _ state1: UIControl.State, _ state2: UIControl.State) -> Self {
        setBackgroundImage(UIImage.image(color: color), for: state1)
        setBackgroundImage(UIImage.image(color: color), for: state2)
        return self
    }
    
    /// 按钮文字内边距
    /// - Parameters:
    ///   - edge: 边距
    /// - Returns: 自身
    @discardableResult
    public func titleEdgeInsets(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> Self {
        titleEdgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    /// 按钮图片内边距
    /// - Parameters:
    ///   - top: 顶部边距
    ///   - left: 左边边距
    ///   - bottom: 底部边距
    ///   - right: 右边边距
    /// - Returns: 自身
    @discardableResult
    public func imageEdgeInsets(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> Self {
        imageEdgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return self
    }
}

extension UIImage {
    
    /// 由颜色生成图片
    /// - Parameter color: 颜色
    /// - Returns: 图片
    public static func image(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        guard let ctx = context else {
            UIGraphicsEndImageContext()
            return nil
        }
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIScrollView {
    
    /// 是否允许滚动 默认 true
    /// - Parameter enabled: 是否滚动
    /// - Returns: 自身
    @discardableResult
    public func isScrollEnabled(_ enabled: Bool = true) -> Self {
        isScrollEnabled = enabled
        return self
    }
    
    /// 是否显示垂直方向滑动条 默认 true
    /// - Parameter show: 是否显示垂直方向滑动条
    /// - Returns: 自身
    @discardableResult
    public func showsVerticalScrollIndicator(_ show: Bool = true) -> Self {
        showsVerticalScrollIndicator = show
        return self
    }
}

extension UITableView {
    
    /// 代理
    /// - Parameter delegate: 代理
    /// - Returns: 自身
    @discardableResult
    public func delegate(_ delegate: UITableViewDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
    
    /// 数据源
    /// - Parameter dataSource: 数据源
    /// - Returns: 自身
    @discardableResult
    public func dataSource(_ dataSource: UITableViewDataSource?) -> Self {
        self.dataSource = dataSource
        return self
    }
    
    /// 行高
    /// - Parameter height: 行高
    /// - Returns: 自身
    @discardableResult
    public func rowHeight(_ height: CGFloat) -> Self {
        rowHeight = height
        return self
    }
    
    /// 单元格预估高度
    /// - Parameter height: 预估高度
    /// - Returns: 自身
    @discardableResult
    public func estimatedRowHeight(_ height: CGFloat) -> Self {
        estimatedRowHeight = height
        return self
    }
    
    /// 分区头部预估高度
    /// - Parameter height: 预估高度
    /// - Returns: 自身
    @discardableResult
    public func estimatedSectionHeaderHeight(_ height: CGFloat) -> Self {
        self.estimatedSectionHeaderHeight = height
        return self
    }
    
    /// 分区尾部预估高度
    /// - Parameter height: 预估高度
    /// - Returns: 自身
    @discardableResult
    public func estimatedSectionFooterHeight(_ height: CGFloat) -> Self {
        self.estimatedSectionFooterHeight = height
        return self
    }
    
    /// 列表尾部 tableFooterView
    /// - Parameter foot: 尾部 View
    /// - Returns: 自身
    @discardableResult
    public func footerView(_ foot: UIView?) -> Self {
        tableFooterView = foot
        return self
    }
    
    /// 单元格的分割线样式  默认 .singleLine
    /// - Parameter style: 分割线样式
    /// - Returns: 自身
    @discardableResult
    public func separatorStyle(_ style: UITableViewCell.SeparatorStyle = .singleLine) -> Self {
        separatorStyle = style
        return self
    }
    
    /// 注册 cell
    /// - Parameter cellClass: cell 类
    /// - Parameter identifier: 复用标识符
    /// - Returns: 自身
    @discardableResult
    public func register(_ cellClass: AnyClass?, identifier: String) -> Self {
        register(cellClass, forCellReuseIdentifier: identifier)
        return self
    }
}

extension UIPickerView {
    
    /// 代理
    /// - Parameter delegate: 代理
    /// - Returns: 自身
    @discardableResult
    public func delegate(_ delegate: UIPickerViewDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
    
    /// 数据源
    /// - Parameter dataSource: 数据源
    /// - Returns: 自身
    @discardableResult
    public func dataSource(_ dataSource: UIPickerViewDataSource?) -> Self {
        self.dataSource = dataSource
        return self
    }
}

extension UIViewController {
    
    /// 返回顶部控制器
    public static func topViewController() -> UIViewController? {
        let window = UIDevice.keyWindow
        if var win = window {
            if win.windowLevel != .normal {
                let windows = UIDevice.windows
                for w in windows {
                    if w.windowLevel == .normal {
                        win = w
                        break
                    }
                }
            }
            var topVc = win.rootViewController
            while topVc?.presentedViewController != nil {
                topVc = topVc?.presentedViewController
            }
            if ((topVc?.isKind(of: UITabBarController.self)) != false) {
                topVc = (topVc as? UITabBarController)?.selectedViewController
            }
            if ((topVc?.isKind(of: UINavigationController.self)) != false) {
                topVc = (topVc as? UINavigationController)?.topViewController
            }
            return topVc
        }else {
            return nil
        }
    }
}
