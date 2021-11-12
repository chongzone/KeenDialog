//
//  KeenHud.swift
//  KeenDialog
//
//  Created by chongzone on 2021/3/7.
//

import UIKit

public extension KeenHud {
    
    /// 显示样式
    enum Style: Int {
        /// 菊花
        case system
        /// 环形
        case torus
    }
}

//MARK: - 属性参数
public struct KeenHudAttributes {
    
    /// 样式 默认 system(菊花)
    public var style: KeenHud.Style = .system
    
    /// 视图圆角 默认 6pt
    public var viewRadius: CGFloat = 6
    /// 视图内边距 默认 top: 0pt left: 5pt bottom: 0pt right: 5pt
    public var viewInset: UIEdgeInsets = UIEdgeInsets(top:0, left:5, bottom:0, right:5)
    /// 视图宽度 默认 125pt
    public var viewWidth: CGFloat = 125
    /// 视图高度 默认 125pt
    public var viewHeight: CGFloat = 125
    /// 视图背景色 默认黑色 透明度 70%
    public var viewBackColor: UIColor = UIColor.black.toColor(of: 0.7)
    
    /// 标题顶部间隔 默认 10pt
    public var titleTopPadding: CGFloat = 10
    /// 标题颜色 默认 #FFFFFF
    public var titleColor: UIColor = UIColor.color(hexString: "#FFFFFF")
    /// 标题字体 默认常规 14pt
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    /// 加载视图宽度 默认 40pt
    public var itemWidth: CGFloat = 40
    /// 加载视图高度 默认 40pt
    public var itemHeight: CGFloat = 40
    /// 自定义的加载视图
    public var customView: UIView?
    
    /// 菊花的颜色 默认 #FFFFFF
    public var systemColor: UIColor = UIColor.color(hexString: "#FFFFFF")
    /// 环形背景色 默认黑色 透明度 10%
    public var torusBackColor: UIColor = UIColor.black.toColor(of: 0.1)
    /// 环形前置背景色 默认 #EFEFEF 透明度 60%
    public var torusForeColor: UIColor = UIColor.color(hexString:"#EFEFEF").toColor(of:0.6)
    
    public init() { }
}

//MARK: - KeenHud 类
public class KeenHud: KeenDialog {
    
    /// 内容
    private var title: String?
    /// 属性参数
    private var attributes: KeenHudAttributes = KeenHudAttributes()
    
    /// 初始化
    /// - Parameters:
    ///   - title: 内容
    ///   - style: 样式 默认系统菊花
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    public init(
        title: String?,
        style: KeenHud.Style = .system,
        attributes: KeenHudAttributes? = nil
    ) {
        self.title = title
        if let attri = attributes { self.attributes = attri }
        self.attributes.style = style
        super.init(frame: .zero)
        self.backColor(self.attributes.viewBackColor)
        self.isClickDisappear = false
        self.maskColor = .clear
        self.style = .hud
    }
    
    /// 初始化
    /// - Parameters:
    ///   - title: 内容
    ///   - customView: 自定义的加载视图
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    public init(
        title: String?,
        customView: UIView,
        attributes: KeenHudAttributes? = nil
    ) {
        self.title = title
        if let attri = attributes { self.attributes = attri }
        self.attributes.customView = customView
        super.init(frame: .zero)
        self.backColor(self.attributes.viewBackColor)
        self.isClickDisappear = false
        self.maskColor = .clear
        self.style = .hud
    }
    
    public override func createSubviews() {
        createHudSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - 布局|配置
private extension KeenHud {
    
    /// 布局控件
    func createHudSubviews() {
        let titleExist: Bool = title != nil && !title!.isEmpty
        let insetWidth = attributes.viewInset.left + attributes.viewInset.right
        let viewSize = CGSize(width: attributes.viewWidth, height: attributes.viewHeight)
        let lineHeight = Double(attributes.titleFont.lineHeight)
        let maxWidth = attributes.viewWidth - insetWidth
        let labelHeight = round(lineHeight)
        
        /// 视图
        self.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(viewSize)
        }
        viewCorner(
            size: viewSize,
            radius: attributes.viewRadius,
            corner: .allCorners
        )
        
        let container = UIView(frame: .zero)
        var totalH: CGFloat = attributes.itemHeight
        if titleExist { totalH += labelHeight + attributes.titleTopPadding }
        container.addViewTo(self)
            .snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(maxWidth)
                make.height.equalTo(totalH)
            }
        
        /// 内容
        if titleExist {
            UILabel()
                .textColor(attributes.titleColor)
                .font(attributes.titleFont)
                .lineMode(.byTruncatingTail)
                .alignment(.center)
                .numberOfLines(1)
                .text(title)
                .addViewTo(container)
                .snp.makeConstraints { (make) in
                    make.left.right.bottom.equalToSuperview()
                    make.height.equalTo(round(lineHeight))
                }
        }
        
        /// 指示器
        var itemView: UIView!
        let offsetB = labelHeight + attributes.titleTopPadding
        let itemSize = CGSize(width: attributes.itemWidth, height: attributes.itemHeight)
        if let customView = attributes.customView {
            itemView = customView
        }else {
            switch attributes.style {
            case .system: itemView = UIActivityIndicatorView(frame:.zero)
            case .torus: itemView = KeenTorusHud(frame:.zero)
            }
        }
        itemView.addViewTo(container)
            .snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.size.equalTo(itemSize)
                if titleExist {
                    make.bottom.equalToSuperview().offset(-offsetB)
                }else {
                    make.centerY.equalToSuperview()
                }
            }
        if attributes.customView == nil {
            switch attributes.style {
            case .system:
                let view = itemView as! UIActivityIndicatorView
                view.hidesWhenStopped = true
                view.isHidden = false
                if #available(iOS 13.0, *) {
                    view.style = .large
                    view.color = attributes.systemColor
                }else {
                    view.style = .whiteLarge
                    view.color = attributes.systemColor
                }
                view.startAnimating()
            case .torus:
                let view = itemView as! KeenTorusHud
                view.config(back:attributes.torusBackColor, fore:attributes.torusForeColor)
                view.startAnimating()
            }
        }
    }
}

//MARK: - KeenTorusHud 类
private class KeenTorusHud: UIView {
    
    var foregroundLayer: CAShapeLayer = {
        return CAShapeLayer()
            .fillColor(.clear)
            .lineCap(.butt)
            .lineWidth(3.0)
            .strokeEnd(0.55)
    }()
    
    var backgroundLayer: CAShapeLayer = {
        return CAShapeLayer()
            .fillColor(.clear)
            .lineCap(.butt)
            .lineWidth(3.0)
            .strokeEnd(1.0)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func config(back backColor: UIColor, fore foreColor: UIColor) {
        foregroundLayer.strokeColor(foreColor)
        backgroundLayer.strokeColor(backColor)
    }
    
    func startAnimating() {
        setNeedsLayout()
        layoutIfNeeded()
        
        let path = UIBezierPath(ovalIn: bounds)
        backgroundLayer.frame(bounds)
            .path(path.cgPath)
            .addLayerTo(layer)
        foregroundLayer.frame(bounds)
            .path(path.cgPath)
            .addLayerTo(layer)
            .basicAnimationKeyPath(
                keyPath: "transform.rotation",
                fromValue: 0,
                toValue: Double.pi,
                duration: 0.4,
                delay: 0,
                repeatCount: .greatestFiniteMagnitude,
                fillMode: .forwards,
                autoreverses: false,
                isCumulative: true,
                removedOnCompletion: false,
                option: .linear,
                animationKey: nil
            )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - KeenHudManager 类
private class KeenHudManager: NSObject {
    
    let huds: NSMapTable<UIView, UIView> = NSMapTable.weakToWeakObjects()
    
    static let kHudViewIdentifier: UIView = UIView()
    
    static let share: KeenHudManager = KeenHudManager()
    
    override init() {
        super.init()
    }
    
    /// hud 加载
    /// - Parameters:
    ///   - title: 内容
    ///   - style: 样式 默认系统菊花
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    ///   - aView: 承载的 view 若是 nil 则取 UIWindow 视图
    func show(
        title: String?,
        style: KeenHud.Style = .system,
        attributes: KeenHudAttributes? = nil,
        aView: UIView? = nil
    ) {
        let hudKey: UIView = KeenHudManager.kHudViewIdentifier
        let block: (() -> ()) = { [weak self] in
            let hud = KeenHud(
                title: title,
                style: style,
                attributes: attributes
            )
            hud.show(aView, animated: true)
            self?.huds.setObject(hud, forKey: hudKey)
        }
        if let hud = huds.object(forKey: hudKey), ((hud as? KeenHud) != nil) {
            huds.removeObject(forKey: hudKey)
            (hud as! KeenHud).dismiss()
            block()
        }else {
            block()
        }
    }
    
    /// hud 加载
    /// - Parameters:
    ///   - title: 内容
    ///   - customView: 自定义的加载视图
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    ///   - aView: 承载的 view 若是 nil 则取 UIWindow 视图
    func show(
        title: String?,
        customView: UIView,
        attributes: KeenHudAttributes? = nil,
        aView: UIView? = nil
    ) {
        let hudKey: UIView = KeenHudManager.kHudViewIdentifier
        let block: (() -> ()) = { [weak self] in
            let hud = KeenHud(
                title: title,
                customView: customView,
                attributes: attributes
            )
            hud.show(aView, animated: true)
            self?.huds.setObject(hud, forKey: hudKey)
        }
        if let hud = huds.object(forKey: hudKey), ((hud as? KeenHud) != nil) {
            huds.removeObject(forKey: hudKey)
            (hud as! KeenHud).dismiss()
            block()
        }else {
            block()
        }
    }
    
    /// hud 消失
    /// - Parameter aView: 承载的 view 若是 nil 则取 UIWindow 视图
    func dismiss(_ aView: UIView? = nil) {
        let hudKey: UIView = KeenHudManager.kHudViewIdentifier
        if let _ = huds.object(forKey: hudKey) as? KeenHud {
            KeenHud.dismiss(aView, animated: true)
        }
    }
}

//MARK: - 弹窗扩展
extension NSObject {
    
    /// hud 加载
    /// - Parameters:
    ///   - title: 内容 默认 正在加载
    ///   - style: 样式 默认系统菊花
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    ///   - aView: 承载的 view 若是 nil 则取 UIWindow 视图
    public func showHud(
        title: String? = "正在加载",
        style: KeenHud.Style = .system,
        attributes: KeenHudAttributes? = nil,
        aView: UIView? = nil
    ) {
        KeenHudManager.share.show(
            title: title,
            style: style,
            attributes: attributes,
            aView: aView
        )
    }
    
    /// hud 加载
    /// - Parameters:
    ///   - title: 内容 默认 正在加载
    ///   - customView: 自定义的加载视图
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    ///   - aView: 承载的 view 若是 nil 则取 UIWindow 视图
    public func showHud(
        title: String? = "正在加载",
        customView: UIView,
        attributes: KeenHudAttributes? = nil,
        aView: UIView? = nil
    ) {
        KeenHudManager.share.show(
            title: title,
            customView: customView,
            attributes: attributes,
            aView: aView
        )
    }
    
    /// hud 消失
    /// - Parameter aView: 承载的 view 若是 nil 则取 UIWindow 视图
    public func dismissHud(_ aView: UIView? = nil) {
        KeenHudManager.share.dismiss(aView)
    }
}
