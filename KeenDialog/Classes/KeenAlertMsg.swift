//
//  KeenAlertMsg.swift
//  KeenDialog
//
//  Created by chongzone on 2021/1/28.
//

import UIKit

public extension KeenAlertMsg {
    
    /// 按钮布局方式
    enum ItemAxisStyle: Int {
        /// 水平排列
        case horizontal
        /// 垂直排列
        case vertical
    }
    
    /// 自定义视图位置
    enum ViewPostion: Int {
        /// 顶部
        case top
        /// 中间
        case middle
        /// 底部
        case bottom
    }
}

//MARK: - 属性参数
public struct KeenAlertMsgAttributes {
    
    /// 视图圆角 默认 8pt
    public var viewRadius: CGFloat = 8
    /// 视图外边距 默认 48pt
    public var viewMargin: CGFloat = 48
    /// 视图内边距 默认 28pt
    public var viewPadding: CGFloat = 28
    
    /// 自定义视图 若控件包含文本框 需设置 observerKeyboard 属性
    public var customView: UIView?
    /// 自定义视图高度 必须指定 否则无效 默认 0
    public var customViewHeight: CGFloat = 0
    /// 自定义视图四周边距  top: 0pt left: 15pt bottom: 20pt right: 15pt
    public var customViewInset = UIEdgeInsets(top:0, left:15, bottom:20, right:15)
    /// 自定义视图位置 其位置相对(标题、消息)  默认 top
    public var position: KeenAlertMsg.ViewPostion = .top
    /// 键盘顶部间隔 默认 20pt 针对自定义视图含有文本框等控件
    public var keyboardMargin: CGFloat = 20
    /// 是否监听键盘事件 默认 false
    public var observerKeyboard: Bool = false
    
    /// 标题顶部间隔 默认 15pt
    public var titleTopPadding: CGFloat = 15
    /// 对齐方式 针对标题或消息多余一行时的情况 默认 left
    public var titleAlignment: NSTextAlignment = .left
    /// 标题颜色 默认 #333333
    public var titleColor: UIColor = UIColor.color(hexString: "#333333")
    /// 标题字体 默认 medium 18pt
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 18, weight: .medium)
    
    /// 消息最小高度
    public var msgMinHeight: CGFloat = 20
    /// 消息最大高度 超过其高度则消息部分可滑动
    public var msgMaxHeight: CGFloat = 300
    /// 消息距上控件的间隔 当消息为空时为标题距下控件的间隔 默认 15pt
    public var msgTopPadding: CGFloat = 15
    /// 消息距下控件的间隔 默认 32pt
    public var msgBottomPadding: CGFloat = 32
    /// 消息颜色 默认 #333333
    public var msgColor: UIColor = UIColor.color(hexString: "#333333")
    /// 消息字体 默认常规 14pt
    public var msgFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    /// 按钮高度 默认 45pt
    public var itemHeight: CGFloat = 45
    /// 按钮布局 默认 horizontal
    public var axisStyle: KeenAlertMsg.ItemAxisStyle = .horizontal
    /// 按钮背景色 默认 #FFFFFF
    public var itemBackColor: UIColor = UIColor.color(hexString: "#FFFFFF")
    /// 按钮高亮时背景色  默认 #E5E5E5
    public var itemHighlightedBackColor: UIColor = UIColor.color(hexString: "#E5E5E5")
    /// 线条的颜色 默认 #EFEFEF
    public var lineColor: UIColor = UIColor.color(hexString: "#EFEFEF")
    
    /// 取消按钮颜色 默认 #969696
    public var cancelColor: UIColor = UIColor.color(hexString: "#969696")
    /// 取消按钮字体 默认常规 18pt
    public var cancelFont: UIFont = UIFont.systemFont(ofSize: 18, weight: .regular)
    /// 确定按钮颜色 默认 #326FFD
    public var doneColor: UIColor = UIColor.color(hexString: "#326FFD")
    /// 确定按钮字体 默认 medium 18pt
    public var doneFont: UIFont = UIFont.systemFont(ofSize: 18, weight: .medium)
    
    public init() { }
}

//MARK: - KeenAlertMsg 类
public class KeenAlertMsg: KeenDialog {
    
    /// 属性参数
    private var attributes: KeenAlertMsgAttributes = KeenAlertMsgAttributes()
    
    /// 标题
    private var title: String?
    /// 消息
    private var msg: String?
    /// 取消按钮标题
    private var cancelTitle: String?
    /// 确定按钮标题
    private var doneTitle: String?
    /// 点击按钮事件回调
    private var callback: ((_ index: Int) -> ())?
    /// 视图标识
    private static let kAlertIdentifier: Int = LONG_MAX - 20
    
    /// 初始化
    /// - Parameters:
    ///   - title: 标题
    ///   - msg: 消息内容
    ///   - cancelTitle: 取消按钮标题
    ///   - doneTitle: 确定按钮标题
    ///   - callback: 按钮事件回调 0 代表左边|下边按钮 1 代表右边|上边按钮
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    public init(
        title: String? = nil,
        msg: String?,
        cancelTitle: String? = "取消",
        doneTitle: String? = "确定",
        callback: ((_ index: Int) -> ())? = nil,
        attributes: KeenAlertMsgAttributes? = nil
    ) {
        self.msg = msg
        self.title = title
        self.callback = callback
        self.doneTitle = doneTitle
        self.cancelTitle = cancelTitle
        super.init(frame: .zero)
        if let attri = attributes {
            if attri.customViewHeight > 0,
               let _ = attri.customView,
               attri.observerKeyboard {
                NotificationCenter.default.addObserver(
                    self,
                    selector:#selector(keyBoardEvent),
                    name: UIResponder.keyboardWillShowNotification,
                    object: nil
                )
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(keyBoardEvent),
                    name: UIResponder.keyboardWillHideNotification,
                    object: nil
                )
            }
            self.attributes = attri
        }
        self.backColor(.white)
        self.style = .alert
    }
    
    public override func createSubviews() {
        createAlertSubviews()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - 布局|配置
private extension KeenAlertMsg {
    
    /// 布局控件
    func createAlertSubviews() {
        let customViewHeight: CGFloat = attributes.customViewHeight
        let totalWidth: CGFloat = .screenWidth - attributes.viewMargin * 2
        let contentWidth: CGFloat = totalWidth - attributes.viewPadding * 2
        let titleExist: Bool = title != nil && !title!.isEmpty
        let msgExist: Bool = msg != nil && !msg!.isEmpty
        let cancelItemExist: Bool = cancelTitle != nil && !cancelTitle!.isEmpty
        let customItemExist: Bool = attributes.customView != nil && customViewHeight > 0
        let customInset = customItemExist ? attributes.customViewInset:.zero
        let insetHeight = customItemExist ? customInset.top + customInset.bottom : 0
        
        /// 标题
        var paddings: CGFloat = 0
        if titleExist { paddings += attributes.msgTopPadding }
        if msgExist { paddings += attributes.msgBottomPadding }
        var viewHeight = customItemExist ? customViewHeight + insetHeight : 0
        var titleHeight: CGFloat = 0
        if titleExist {
            titleHeight = title!.calculateSize(
                font: attributes.titleFont,
                width: contentWidth,
                height: .greatestFiniteMagnitude
            ).height
            paddings += attributes.titleTopPadding
        }
        var lineHeight = attributes.titleFont.lineHeight
        let titleLineCount = lroundf(Float(titleHeight))/lroundf(Float(lineHeight))
        if titleExist {
            let titleLabel = UILabel()
                .alignment(titleLineCount < 2 ? .center : attributes.titleAlignment)
                .lineMode(.byTruncatingTail)
                .backColor(.white)
                .textColor(attributes.titleColor)
                .text(self.title!)
                .numberOfLines(0)
                .addViewTo(self)
            var offsetY: CGFloat = attributes.titleTopPadding
            if customItemExist, attributes.position == .top {
                offsetY = offsetY + customViewHeight + insetHeight
            }
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(attributes.viewPadding)
                make.right.equalToSuperview().offset(-attributes.viewPadding)
                make.top.equalToSuperview().offset(offsetY)
                make.height.equalTo(titleHeight)
            }
        }
        
        /// 消息
        var msgHeight: CGFloat = 0
        if msgExist {
            msgHeight = msg!.calculateSize(
                font: attributes.msgFont,
                width: contentWidth,
                height: .greatestFiniteMagnitude
            ).height
        }
        lineHeight = attributes.msgFont.lineHeight
        let msgLineCount = lroundf(Float(msgHeight))/lroundf(Float(lineHeight))
        if msgExist {
            let minHeight = max(msgHeight, attributes.msgMinHeight)
            msgHeight = min(minHeight, attributes.msgMaxHeight)
            
            var msgView: UIView!
            let spill: Bool = msgHeight > attributes.msgMaxHeight ? true : false
            if spill {
                msgView = KeenTextView()
                    .isScrollEnabled(spill)
                    .isSelectable(false)
                    .isEditable(false)
                    .alignment(msgLineCount < 2 ? .center : attributes.titleAlignment)
                    .backColor(.white)
                    .textInset(.zero)
                    .textColor(attributes.msgColor)
                    .font(attributes.msgFont)
                    .text(msg!)
                    .addViewTo(self)
            }else {
                msgView = UILabel()
                    .font(attributes.msgFont)
                    .textColor(attributes.msgColor)
                    .alignment(msgLineCount < 2 ? .center : attributes.titleAlignment)
                    .backColor(.white)
                    .numberOfLines(0)
                    .text(msg)
                    .addViewTo(self)
            }
            var titleBottom: CGFloat = 0
            if titleExist {
                titleBottom = titleHeight + attributes.titleTopPadding
            }
            var offsetY = titleBottom + attributes.msgTopPadding
            if customItemExist,
               (attributes.position == .top ||
               attributes.position == .middle) {
                offsetY = offsetY + customViewHeight + insetHeight
            }
            msgView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(attributes.viewPadding)
                make.right.equalToSuperview().offset(-attributes.viewPadding)
                make.top.equalToSuperview().offset(offsetY)
                make.height.equalTo(msgHeight)
            }
        }
        
        /// 视图
        viewHeight = paddings + titleHeight + msgHeight + attributes.itemHeight + 0.5
        if customItemExist {
            viewHeight += customViewHeight + insetHeight
        }
        if attributes.axisStyle == .vertical, cancelItemExist {
            viewHeight += attributes.itemHeight
        }
        self.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: totalWidth, height: viewHeight))
            make.center.equalToSuperview()
        }
        viewCorner(
            size: CGSize(width: totalWidth, height: viewHeight),
            radius: attributes.viewRadius,
            corner: .allCorners
        )
        
        /// 自定义视图
        if customItemExist {
            let custom = attributes.customView!
            custom.addViewTo(self)
            switch attributes.position {
            case .top:
                custom.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset(customInset.left)
                    make.right.equalToSuperview().offset(-customInset.right)
                    make.top.equalToSuperview().offset(customInset.top)
                    make.height.equalTo(customViewHeight)
                }
            case .middle:
                var offsetY: CGFloat = customInset.top
                if titleExist {
                    offsetY += titleHeight + attributes.titleTopPadding
                    if msgExist == false {
                        offsetY += attributes.msgTopPadding
                    }
                }
                custom.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset(customInset.left)
                    make.right.equalToSuperview().offset(-customInset.right)
                    make.top.equalToSuperview().offset(offsetY)
                    make.height.equalTo(customViewHeight)
                }
            case .bottom:
                var offsetB = attributes.itemHeight + 0.5 + customInset.bottom
                if attributes.axisStyle == .vertical {
                    offsetB = offsetB + attributes.itemHeight
                }
                custom.snp.makeConstraints { (make) in
                    make.height.equalTo(customViewHeight)
                    make.bottom.equalToSuperview().offset(-offsetB)
                    make.left.equalToSuperview().offset(customInset.left)
                    make.right.equalToSuperview().offset(-customInset.right)
                }
            }
        }
        
        /// 横线
        let lineView = UIView()
            .backColor(attributes.lineColor)
            .addViewTo(self)
        lineView.snp.makeConstraints { (make) in
            if attributes.axisStyle == .horizontal {
                make.bottom.equalToSuperview().offset(-attributes.itemHeight-0.5)
            }else {
                make.bottom.equalToSuperview().offset(-attributes.itemHeight*2-0.5)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        /// 按钮
        let doneItem = UIButton(type: .custom)
            .titleColor(attributes.doneColor, .normal, .highlighted)
            .backColor(attributes.itemBackColor, .normal)
            .backColor(attributes.itemHighlightedBackColor, .highlighted)
            .font(attributes.doneFont)
            .title(doneTitle)
            .tag(KeenAlertMsg.kAlertIdentifier + 1)
            .addViewTo(self)
        doneItem.addTarget(
            self,
            action: #selector(clickAlertItemEvent(sender:)),
            for: .touchUpInside
        )
        if cancelItemExist == false {
            doneItem.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(lineView.snp.bottom)
            }
        }else {
            switch attributes.axisStyle {
            case .horizontal:
                doneItem.snp.makeConstraints { (make) in
                    make.left.equalTo(self.snp.centerX)
                    make.top.equalTo(lineView.snp.bottom)
                    make.right.bottom.equalToSuperview()
                }
            case .vertical:
                doneItem.snp.makeConstraints { (make) in
                    make.top.equalTo(lineView.snp.bottom)
                    make.height.equalTo(attributes.itemHeight)
                    make.left.right.equalToSuperview()
                }
            }
            
            let cancelItem = UIButton(type: .custom)
                .titleColor(attributes.cancelColor, .normal, .highlighted)
                .backColor(attributes.itemBackColor, .normal)
                .backColor(attributes.itemHighlightedBackColor, .highlighted)
                .font(attributes.cancelFont)
                .title(cancelTitle)
                .tag(KeenAlertMsg.kAlertIdentifier + 0)
                .addViewTo(self)
            switch attributes.axisStyle {
            case .horizontal:
                cancelItem.snp.makeConstraints { (make) in
                    make.right.equalTo(self.snp.centerX)
                    make.top.equalTo(lineView.snp.bottom)
                    make.left.bottom.equalToSuperview()
                }
            case .vertical:
                cancelItem.snp.makeConstraints { (make) in
                    make.top.equalTo(lineView.snp.bottom).offset(attributes.itemHeight)
                    make.height.equalTo(attributes.itemHeight)
                    make.left.right.equalToSuperview()
                }
            }
            cancelItem.addTarget(
                self,
                action: #selector(clickAlertItemEvent(sender:)),
                for: .touchUpInside
            )
            
            let vlineView = UIView()
                .backColor(attributes.lineColor)
                .addViewTo(self)
            vlineView.snp.makeConstraints { (make) in
                if attributes.axisStyle == .horizontal {
                    make.left.equalTo(self.snp.centerX).offset(-0.25)
                    make.right.equalTo(self.snp.centerX).offset(0.25)
                    make.top.equalTo(lineView.snp.bottom)
                    make.bottom.equalToSuperview()
                }else {
                    make.bottom.equalToSuperview().offset(-attributes.itemHeight-0.5)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(0.5)
                }
            }
        }
    }
    
    /// 按钮点击事件
    /// - Parameter index: 0 代表左边|下边按钮 1 代表右边|上边按钮
    @objc func clickAlertItemEvent(sender: UIButton) {
        var flag: Bool = false
        if attributes.customViewHeight > 0,
           let _ = attributes.customView,
           attributes.observerKeyboard {
            NotificationCenter.default.removeObserver(self)
            flag = true
        }
        dismiss({ [weak self] in
            if flag { self?.endEditing(true) }
            if let c = self?.callback { c(sender.tag - KeenAlertMsg.kAlertIdentifier) }
        }, animated: true)
    }
    
    /// 键盘事件
    @objc func keyBoardEvent(_ notification: Notification) {
        let dict = notification.userInfo
        let beginKey: String = UIResponder.keyboardFrameBeginUserInfoKey
        let endKey: String = UIResponder.keyboardFrameEndUserInfoKey
        guard (dict?[beginKey] as? CGRect) != nil,
              (dict?[endKey] as? CGRect) != nil
        else { return }
        
        let endFrame = (dict?[endKey] as! NSValue).cgRectValue
        let keyboardHeight = CGFloat.screenHeight - endFrame.origin.y
        if notification.name.rawValue == "UIKeyboardWillShowNotification" {
            let padding = (.screenHeight - height) * 0.5 - attributes.keyboardMargin
            let translationY: CGFloat = padding - keyboardHeight
            transform = CGAffineTransform(translationX: 0, y: translationY)
        }else {
            transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
}

private class KeenTextView: UITextView {
    
    /// 禁止弹出菜单
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

//MARK: - 弹窗扩展
extension NSObject {
    
    /// alert  弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - msg: 消息内容
    ///   - cancelTitle: 取消按钮标题
    ///   - doneTitle: 确定按钮标题
    ///   - callback: 回调信息 0 代表取消事件 1 代表确定事件
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    public func showAlert(
        title: String? = nil,
        msg: String?,
        cancelTitle: String? = "取消",
        doneTitle: String? = "确定",
        callback: ((_ index: Int) -> ())? = nil,
        attributes: KeenAlertMsgAttributes? = nil
    ) {
        let alert = KeenAlertMsg(
            title: title,
            msg: msg,
            cancelTitle: cancelTitle,
            doneTitle: doneTitle,
            callback: callback,
            attributes: attributes
        )
        alert.show()
    }
}
