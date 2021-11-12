//
//  KeenToast.swift
//  KeenDialog
//
//  Created by chongzone on 2021/3/5.
//

import UIKit

public extension KeenToast {
    
    /// 吐司位置
    enum Postion: Int {
        /// 顶部
        case top
        /// 居中
        case center
        /// 底部
        case bottom
    }
}

//MARK: - 属性参数
public struct KeenToastAttributes {
    
    /// 视图圆角 默认 4pt
    public var viewRadius: CGFloat = 4
    /// 视图背景色 默认黑色 透明度 70%
    public var viewBackColor: UIColor = UIColor.black.toColor(of: 0.7)
    /// 视图左右的外边距 默认 40pt
    public var viewMargin: CGFloat = 40
    /// 视图内边距 默认 top: 8pt left: 15pt bottom: 8pt right: 15pt
    public var viewInset: UIEdgeInsets = UIEdgeInsets(top:8, left:15, bottom:8, right:15)
    /// 视图距离父视图顶部的偏移量 默认 100pt
    public var viewOffsetTop: CGFloat = 100 + CGFloat.safeAreaTopHeight
    /// 视图距离父视图底部的偏移量 默认 100pt
    public var viewOffsetBottom: CGFloat = 100 + CGFloat.safeAreaBottomHeight
    
    /// 视图位置 默认 center
    public var position: KeenToast.Postion = .center
    /// 字体颜色 默认 #FFFFFF
    public var titleColor: UIColor = UIColor.color(hexString: "#FFFFFF")
    /// 字体大小 默认常规 16pt
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    
    public init() { }
}

//MARK: - KeenToast 类
public class KeenToast: KeenDialog {
    
    /// 内容
    private var title: String!
    /// 属性参数
    private var attributes: KeenToastAttributes = KeenToastAttributes()
    
    /// 初始化
    /// - Parameters:
    ///   - title: 内容
    ///   - duration: 吐司时长 默认 2s
    ///   - position: 显示位置 默认 居中
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    public init(
        title: String,
        duration: Double = 2,
        position: KeenToast.Postion = .center,
        attributes: KeenToastAttributes? = nil
    ) {
        self.title = title
        if let attri = attributes { self.attributes = attri }
        self.attributes.position = position
        super.init(frame: .zero)
        self.backColor(self.attributes.viewBackColor)
        self.isClickDisappear = false
        self.duration = duration
        self.maskColor = .clear
        self.style = .toast
    }
    
    public override func createSubviews() {
        createToastSubviews()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - 布局|配置
private extension KeenToast {
    
    /// 布局控件
    func createToastSubviews() {
        let containerWidth = self.superview!.width
        var maxWidth = containerWidth - attributes.viewMargin * 2
        var labelSize = title.calculateSize(font: attributes.titleFont)
        let insetWidth = attributes.viewInset.left + attributes.viewInset.right
        let insetHeight = attributes.viewInset.top + attributes.viewInset.bottom
        if labelSize.width > maxWidth - insetWidth {
            labelSize.width = maxWidth - insetWidth
            labelSize.height = title.calculateSize(
                font: attributes.titleFont,
                width: labelSize.width
            ).height
        }
        maxWidth = min(maxWidth, labelSize.width + insetWidth)
        
        /// 内容
        UILabel()
            .textColor(attributes.titleColor)
            .font(attributes.titleFont)
            .lineMode(.byTruncatingTail)
            .alignment(.left)
            .numberOfLines(0)
            .text(title)
            .addViewTo(self)
            .snp.makeConstraints { (make) in
                make.height.equalTo(labelSize.height)
                make.width.equalTo(labelSize.width)
                make.center.equalToSuperview()
            }
        
        /// 视图
        let totalHeight = labelSize.height + insetHeight
        self.snp.makeConstraints { make in
            make.width.equalTo(maxWidth)
            make.height.equalTo(totalHeight)
            switch self.attributes.position {
            case .top:
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(attributes.viewOffsetTop)
            case .center:
                make.center.equalToSuperview()
            case .bottom:
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-attributes.viewOffsetBottom)
            }
        }
        viewCorner(
            size: CGSize(width: maxWidth, height: totalHeight),
            radius: attributes.viewRadius,
            corner: .allCorners
        )
    }
}

//MARK: - 弹窗扩展
extension NSObject {
    
    /// toast 弹窗
    /// - Parameters:
    ///   - title: 内容
    ///   - duration: 吐司时长 默认 2s
    ///   - position: 显示位置 默认 居中
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    ///   - aView: 承载的 view 若是 nil 则取 UIWindow 视图
    public func showToast(
        title: String,
        duration: Double = 2,
        position: KeenToast.Postion = .center,
        attributes: KeenToastAttributes? = nil,
        aView: UIView? = nil
    ) {
        let toast = KeenToast(
            title: title,
            duration: duration,
            position: position,
            attributes: attributes
        )
        toast.show(aView, animated: true)
    }
}
