//
//  KeenActionSheet.swift
//  KeenDialog
//
//  Created by chongzone on 2021/1/31.
//

import UIKit

//MARK: - 属性参数
public struct KeenActionSheetAttributes {
    
    /// 视图圆角 默认 8pt
    public var viewRadius: CGFloat = 8
    /// 视图背景色 默认 #FFFFFF
    public var viewBackColor: UIColor = UIColor.color(hexString: "#FFFFFF")
    
    /// 标题高度 默认 40pt
    public var titleHeight: CGFloat = 40
    /// 标题颜色 默认 #333333
    public var titleColor: UIColor = UIColor.color(hexString: "#333333")
    /// 标题字体 默认常规 14pt
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    /// 凸显 item 下标  默认 -1
    public var highlightedIndex: Int = -1
    /// 凸显 item 标题颜色 默认 #FF4644
    public var highlightedColor: UIColor = UIColor.color(hexString: "#FF4644")
    
    /// item 高度 默认 50pt
    public var itemHeight: CGFloat = 50
    /// item 高度 仅针对有子标题的 item  默认 60pt
    public var itemMoreHeight: CGFloat = 60
    /// item 区域最大的可视高度 默认 300pt 超过最大高度 item 区域可滑动
    public var itemViewMaxHeight: CGFloat = 300
    /// item 标题颜色 默认 #333333
    public var itemColor: UIColor = UIColor.color(hexString: "#333333")
    /// item 标题字体 默认常规 16pt
    public var itemFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    /// item 子标题颜色 默认 #999999
    public var subItemColor: UIColor = UIColor.color(hexString: "#999999")
    /// item 子标题字体 默认常规 12pt
    public var subItemFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    /// item 背景色 默认 #FFFFFF
    public var itemBackColor: UIColor = UIColor.color(hexString: "#FFFFFF")
    /// item 高亮时背景色 默认 #E5E5E5
    public var itemHighlightedBackColor: UIColor = UIColor.color(hexString: "#E5E5E5")
    
    /// 取消按钮颜色 默认 #333333
    public var cancelColor: UIColor = UIColor.color(hexString: "#333333")
    /// 取消按钮字体 默认常规 16pt
    public var cancelFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    
    /// 分割的高度
    public var separatorHeight: CGFloat = 10
    /// 分隔的背景色 默认 #F5F5F5
    public var separatorBackColor: UIColor = UIColor.color(hexString: "#F5F5F5")
    /// 分割线条的颜色 默认 #EFEFEF
    public var lineColor: UIColor = UIColor.color(hexString: "#EFEFEF")
    
    public init() { }
}

//MARK: - KeenActionSheet 类
public class KeenActionSheet: KeenDialog {
    
    /// 属性参数
    private var attributes: KeenActionSheetAttributes = KeenActionSheetAttributes()
    
    /// 标题
    private var title: String?
    /// 数据源
    private var items: [String]!
    /// 取消按钮标题
    private var cancelTitle: String?
    /// 点击取消按钮回调
    private var cancelback: (() -> ())?
    /// 点击 item 事件回调
    private var callback: ((_ index: Int) -> ())?
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
            .showsVerticalScrollIndicator(false)
            .estimatedSectionHeaderHeight(0)
            .estimatedSectionFooterHeight(0)
            .estimatedRowHeight(0)
            .separatorStyle(.none)
            .dataSource(self)
            .delegate(self)
            .footerView(UIView())
            .isScrollEnabled(false)
            .backColor(attributes.viewBackColor)
            .register(KeenActionSheetCell.self, identifier: KeenActionSheetCell.className)
        if #available(iOS 11, *) { view.contentInsetAdjustmentBehavior = .never }
        return view
    }()
    
    /// 初始化
    /// - Parameters:
    ///   - title: 标题
    ///   - items: 数据源标题
    ///   - highlightedIndex: 凸显的 item 下标 默认都不凸显
    ///   - cancelTitle: 取消按钮
    ///   - callback: item 事件回调 其中 0 对应最上面的 item 控件
    ///   - cancel: 取消按钮回调
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    public init(
        title: String? = nil,
        items: [String],
        highlightedIndex: Int = -1,
        cancelTitle: String? = "取消",
        callback: @escaping ((_ index: Int) -> ()),
        cancel: (() -> ())? = nil,
        attributes: KeenActionSheetAttributes?
    ) {
        self.title = title
        self.items = items
        if let attri = attributes { self.attributes = attri }
        self.attributes.highlightedIndex = highlightedIndex
        self.cancelTitle = cancelTitle
        self.callback = callback
        self.cancelback = cancel
        super.init(frame: .zero)
        self.backColor(self.attributes.viewBackColor)
        self.isClickDisappear = true
        self.style = .actionSheet
    }
    
    public override func createSubviews() {
        createAlertSubviews()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - 布局|配置
private extension KeenActionSheet {
    
    /// 布局控件
    func createAlertSubviews() {
        let titleExist: Bool = title != nil && !title!.isEmpty
        let cancelItemExist: Bool = cancelTitle != nil && !cancelTitle!.isEmpty
        var subItemCount: Int = 0
        for idx in 0..<items.count {
            let content = items[idx].components(separatedBy: "\n")
            if content.count > 1 {
                subItemCount += 1
            }
        }
        let separatorHeight = attributes.separatorHeight
        let padding = cancelItemExist ? (separatorHeight+attributes.itemHeight) : 0
        let itemMoreHeight = CGFloat(subItemCount) * attributes.itemMoreHeight
        let itemHeight = CGFloat(items.count - subItemCount) * attributes.itemHeight
        var itemViewHeight = itemHeight + itemMoreHeight
        itemViewHeight = min(itemViewHeight, attributes.itemViewMaxHeight)
        var viewHeight = itemViewHeight + padding + CGFloat.safeAreaBottomHeight
        if titleExist { viewHeight += attributes.titleHeight }
        
        /// 视图
        self.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(viewHeight)
        }
        viewCorner(
            size: CGSize(width: .screenWidth, height: viewHeight),
            radius: attributes.viewRadius,
            corner: [.topLeft, .topRight]
        )
        
        /// 标题
        var offsetY: CGFloat = 0.0
        if titleExist {
            UILabel()
                .textColor(attributes.titleColor)
                .font(attributes.titleFont)
                .lineMode(.byTruncatingTail)
                .alignment(.center)
                .backColor(attributes.viewBackColor)
                .text(title!)
                .addViewTo(self)
                .snp.makeConstraints { (make) in
                    make.top.left.right.equalToSuperview()
                    make.height.equalTo(attributes.titleHeight)
                }
            offsetY += attributes.titleHeight
            
            UIView()
                .backColor(attributes.lineColor)
                .addViewTo(self)
                .snp.makeConstraints { make in
                    make.top.equalToSuperview().offset(attributes.titleHeight-0.5)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(0.5)
                }
        }
        
        /// item
        tableView.addViewTo(self)
            .isScrollEnabled(itemHeight+itemMoreHeight > attributes.itemViewMaxHeight)
            .snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(offsetY)
                make.left.right.equalToSuperview()
                make.height.equalTo(itemViewHeight)
            }
        
        /// 分隔区域
        UIView()
            .backColor(attributes.separatorBackColor)
            .addViewTo(self)
            .snp.makeConstraints { make in
                make.top.equalTo(tableView.snp.bottom)
                make.height.equalTo(separatorHeight)
                make.left.right.equalToSuperview()
            }
        
        /// 取消按钮
        if cancelItemExist {
            let cancelItem = UIButton(type: .custom)
                .backColor(attributes.itemBackColor, .normal)
                .backColor(attributes.itemHighlightedBackColor, .highlighted)
                .titleColor(attributes.cancelColor, .normal, .highlighted)
                .font(attributes.cancelFont)
                .title(cancelTitle)
                .addViewTo(self)
            cancelItem.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(attributes.itemHeight)
                make.bottom.equalToSuperview().offset(-CGFloat.safeAreaBottomHeight)
            }
            cancelItem.addTarget(
                self,
                action: #selector(clickCancelEvent(sender:)),
                for: .touchUpInside
            )
        }
    }
    
    @objc func clickCancelEvent(sender: UIButton) {
        dismiss({ [weak self] in
            if let c = self?.cancelback {
                c()
            }
        }, animated: true)
    }
}

//MARK: - UITableViewDataSource 数据源
extension KeenActionSheet: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: KeenActionSheetCell.className, for: indexPath) as! KeenActionSheetCell
        if items.count > 0 {
            let content = items[indexPath.row].components(separatedBy: "\n")
            cell.attributes = attributes
            cell.config(
                index: indexPath.row,
                title: content.first!,
                subTitle: content.count > 1 ? content.last! : nil,
                showLine: indexPath.row != items.count - 1
            )
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let content = items[indexPath.row].components(separatedBy: "\n")
        return content.count > 1 ? attributes.itemMoreHeight : attributes.itemHeight
    }
}

//MARK: - UITableViewDelegate 代理
extension KeenActionSheet: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss({ [weak self] in
            if let c = self?.callback {
                c(indexPath.row)
            }
        }, animated: true)
    }
}

//MARK: - KeenActionSheetCell 类
private class KeenActionSheetCell: UITableViewCell {
    
    lazy var itemLabel: UILabel = {
        return UILabel()
            .lineMode(.byTruncatingTail)
            .alignment(.center)
    }()
    
    lazy var subItemLabel: UILabel = {
        return UILabel()
            .lineMode(.byTruncatingTail)
            .alignment(.center)
    }()
    
    lazy var lineView: UIView = {
        return UIView(frame: .zero)
    }()
    
    var attributes: KeenActionSheetAttributes! {
        didSet {
            itemLabel.font(attributes.itemFont)
                .textColor(attributes.itemColor)
            
            subItemLabel.font(attributes.subItemFont)
                .textColor(attributes.subItemColor)
            
            lineView.backColor(attributes.lineColor)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        itemLabel.addViewTo(contentView)
            .snp.makeConstraints { make in
                make.centerX.equalTo(contentView)
                make.centerY.equalTo(contentView)
            }
        
        subItemLabel.addViewTo(contentView)
            .snp.makeConstraints { make in
                make.top.equalTo(itemLabel.snp.bottom)
                make.centerX.equalTo(contentView)
            }
        
        lineView.addViewTo(contentView)
            .snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(0.5)
            }
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(index: Int, title: String, subTitle: String?, showLine: Bool) {
        if let sub = subTitle {
            let subHeight = sub.calculateSize(
                font: attributes.subItemFont,
                width: contentView.width,
                height: .greatestFiniteMagnitude
            ).height
            itemLabel.snp.updateConstraints { make in
                make.centerY.equalTo(contentView).offset(-subHeight * 0.5)
            }
            subItemLabel.text(sub)
        }else {
            itemLabel.snp.updateConstraints { make in
                make.centerY.equalTo(contentView)
            }
        }
        if index == attributes.highlightedIndex {
            itemLabel.textColor(attributes.highlightedColor)
        }else {
            itemLabel.textColor(attributes.itemColor)
        }
        itemLabel.text(title)
        subItemLabel.isHidden = subTitle == nil
        lineView.isHidden = !showLine
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if let _ = attributes {
            if highlighted {
                contentView.backColor(attributes.itemHighlightedBackColor)
            }else {
                UIView.animate(
                    withDuration: 0.1,
                    delay: 0.1,
                    options: .curveEaseInOut
                ) {
                    self.contentView.backColor(self.attributes.itemBackColor)
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if let _ = attributes {
            if selected {
                contentView.backColor(attributes.itemHighlightedBackColor)
            }else {
                contentView.backColor(attributes.itemBackColor)
            }
        }
    }
}

//MARK: - 弹窗扩展
extension NSObject {
    
    /// actionSheet 弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - items: 数据源标题
    ///   - highlightedIndex: 凸显的 item 下标 默认都不凸显
    ///   - cancelTitle: 取消按钮标题
    ///   - callback: item 事件回调 其中 0 对应最上面的 item 控件
    ///   - cancel: 取消按钮回调
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    public func showActionSheet(
        title: String? = nil,
        items: [String],
        highlightedIndex: Int = -1,
        cancelTitle: String? = "取消",
        callback: @escaping ((_ index: Int) -> ()),
        cancel: (() -> ())? = nil,
        attributes: KeenActionSheetAttributes? = nil
    ) {
        let actionSheet = KeenActionSheet(
            title: title,
            items: items,
            highlightedIndex: highlightedIndex,
            cancelTitle: cancelTitle,
            callback: callback,
            cancel: cancel,
            attributes: attributes
        )
        actionSheet.show()
    }
}
