//
//  KeenMenuList.swift
//  KeenDialog
//
//  Created by chongzone on 2021/3/5.
//

import UIKit

public extension KeenMenuList {
    
    /// 箭头位置
    enum ArrowPostion: Int {
        /// 顶部
        case top
        /// 底部
        case bottom
    }
}

//MARK: - 属性参数
public struct KeenMenuListAttributes {
    
    /// 视图位置 默认屏幕原点
    public var viewOrigin: CGPoint = .zero
    /// 视图圆角 默认 8pt
    public var viewRadius: CGFloat = 8
    /// 视图宽度 默认 75pt
    public var viewWidth: CGFloat = 75
    /// 视图背景色 默认 #FFFFFF
    public var viewBackColor: UIColor = UIColor.color(hexString: "#FFFFFF")
    
    /// 箭头宽度 默认 16pt
    public var arrowWidth: CGFloat = 16
    /// 箭头高度 默认 10pt
    public var arrowHeight: CGFloat = 10
    /// 箭头位置 默认 top
    public var position: KeenMenuList.ArrowPostion = .top
    
    /// 凸显 item 下标  默认 -1
    public var highlightedIndex: Int = -1
    /// 凸显 item 标题颜色 默认 #FF4644
    public var highlightedColor: UIColor = UIColor.color(hexString: "#FF4644")
    
    /// item 内边距 默认左边间隔 15pt 其他 0pt
    public var itemInset: UIEdgeInsets = UIEdgeInsets(top:0, left:15, bottom:0, right:0)
    /// item 间隔 默认 10pt
    public var itemPadding: CGFloat = 10
    /// item 高度 默认 45pt
    public var itemHeight: CGFloat = 45
    /// item 标题对齐方式 默认距左
    public var itemAlignment: NSTextAlignment = .left
    /// item 标题颜色 默认 #333333
    public var itemColor: UIColor = UIColor.color(hexString: "#333333")
    /// item 标题字体 默认常规 16pt
    public var itemFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    /// item 背景色 默认 #FFFFFF
    public var itemBackColor: UIColor = UIColor.color(hexString: "#FFFFFF")
    /// item 高亮时背景色 默认 #E5E5E5
    public var itemHighlightedBackColor: UIColor = UIColor.color(hexString: "#E5E5E5")
    
    /// 分割线条的颜色 默认 #EFEFEF
    public var lineColor: UIColor = UIColor.color(hexString: "#EFEFEF")
    /// 分割线条内边距 默认左边间隔 15pt 其他 0pt
    public var lineInset: UIEdgeInsets = UIEdgeInsets(top:0, left:15, bottom:0, right:0)
    
    public init() { }
}

//MARK: - KeenMenuList 类
public class KeenMenuList: KeenDialog {
    
    /// 属性参数
    private var attributes: KeenMenuListAttributes = KeenMenuListAttributes()
    
    /// 图标集合
    private var imgs: [String]?
    /// 标题集合
    private var items: [String]!
    /// 箭头相对视图的偏移量
    private var offsetX: CGFloat = 0
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
            .rowHeight(attributes.itemHeight)
            .footerView(UIView())
            .isScrollEnabled(false)
            .backColor(attributes.viewBackColor)
            .register(KeenMenuListCell.self, identifier: KeenMenuListCell.className)
        if #available(iOS 11, *) { view.contentInsetAdjustmentBehavior = .never }
        return view
    }()
    
    /// 初始化
    /// - Parameters:
    ///   - position: 箭头位置 默认 top
    ///   - origin: 视图位置 (x、y 坐标)
    ///   - imgs: 数据源图标
    ///   - items: 数据源标题
    ///   - offsetX: 箭头顶点相对视图的左偏移量(箭头宽度默认 16pt)
    ///   - highlightedIndex: 凸显的 item 下标 默认都不凸显
    ///   - callback: item 事件回调
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    public init(
        position: KeenMenuList.ArrowPostion = .top,
        origin: CGPoint,
        imgs: [String]? = nil,
        items: [String],
        offsetX: CGFloat,
        highlightedIndex: Int = -1,
        callback: ((_ index: Int) -> ())?,
        attributes: KeenMenuListAttributes? = nil
    ) {
        self.imgs = imgs
        self.items = items
        self.offsetX = offsetX
        if let attri = attributes { self.attributes = attri }
        self.attributes.highlightedIndex = highlightedIndex
        self.attributes.viewOrigin = origin
        self.attributes.position = position
        self.callback = callback
        super.init(frame: .zero)
        self.backColor(.clear)
        self.maskColor = UIColor.black.toColor(of: 0.2)
        self.isClickDisappear = true
        self.style = .menu
    }
    
    /// 箭头
    public override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        guard let ctx = context else {
            return
        }
        let arrowH = attributes.arrowHeight
        let arrowX = attributes.arrowWidth * 0.5
        var locations: [CGPoint] = [CGPoint](repeating: .zero, count: 0)
        switch attributes.position {
        case .top:
            locations.append(CGPoint(x: offsetX, y: 0))
            locations.append(CGPoint(x: offsetX - arrowX, y: arrowH))
            locations.append(CGPoint(x: offsetX + arrowX, y: arrowH))
        case .bottom:
            let itemHeight = CGFloat(items.count) * attributes.itemHeight
            locations.append(CGPoint(x: offsetX, y: itemHeight+arrowH))
            locations.append(CGPoint(x: offsetX - arrowX, y: itemHeight))
            locations.append(CGPoint(x: offsetX + arrowX, y: itemHeight))
        }
        ctx.addLines(between: locations)
        ctx.setFillColor(attributes.viewBackColor.cgColor)
        ctx.setStrokeColor(attributes.viewBackColor.cgColor)
        ctx.closePath()
        
        ctx.drawPath(using: .fillStroke)
    }
    
    public override func createSubviews() {
        createMenuSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - 布局|配置
private extension KeenMenuList {
    
    /// 布局控件
    func createMenuSubviews() {
        let itemHeight = CGFloat(items.count) * attributes.itemHeight
        
        /// 视图
        self.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(attributes.viewOrigin.x)
            make.top.equalToSuperview().offset(attributes.viewOrigin.y)
            make.height.equalTo(itemHeight + attributes.arrowHeight)
            make.width.equalTo(attributes.viewWidth)
        }
        
        /// item
        var offsetY: CGFloat = 0.0
        var offsetB: CGFloat = 0.0
        switch attributes.position {
        case .top:
            offsetY = attributes.arrowHeight
            offsetB = 0
        case .bottom:
            offsetY = 0
            offsetB = attributes.arrowHeight
        }
        tableView.addViewTo(self)
            .snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-offsetB)
                make.top.equalToSuperview().offset(offsetY)
                make.left.right.equalToSuperview()
            }
        tableView.viewCorner(
            size: CGSize(width: attributes.viewWidth, height: itemHeight),
            radius: attributes.viewRadius,
            corner: .allCorners
        )
    }
}

//MARK: - UITableViewDataSource 数据源
extension KeenMenuList: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: KeenMenuListCell.className, for: indexPath) as! KeenMenuListCell
        if items.count > 0 {
            cell.attributes = attributes
            cell.config(
                icon: imgs?[indexPath.row],
                title: items[indexPath.row],
                showLine: indexPath.row != items.count - 1
            )
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSelected(indexPath.row == attributes.highlightedIndex, animated: true)
        if indexPath.row == attributes.highlightedIndex {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

//MARK: - UITableViewDelegate 代理
extension KeenMenuList: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss({ [weak self] in
            self?.callback?(indexPath.row)
        }, animated: true)
    }
}

//MARK: - KeenMenuCell 类
private class KeenMenuListCell: UITableViewCell {
    
    lazy var itemIcon: UIImageView = {
        return UIImageView(frame: .zero)
            .isUserInteractionEnabled(true)
            .contentMode(.scaleAspectFill)
            .clipsToBounds(true)
    }()
    
    lazy var titleLable: UILabel = {
        return UILabel(frame: .zero)
            .isUserInteractionEnabled(true)
            .lineMode(.byTruncatingTail)
    }()
    
    lazy var lineView: UIView = {
        return UIView(frame: .zero)
    }()
    
    var attributes: KeenMenuListAttributes! {
        didSet {
            titleLable.font(attributes.itemFont)
                .textColor(attributes.itemColor)
                .alignment(attributes.itemAlignment)
            
            lineView.backColor(attributes.lineColor)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        itemIcon.addViewTo(contentView)
            .snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
                make.size.equalTo(CGSize.zero)
            }
        
        titleLable.addViewTo(contentView)
            .snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview()
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
    
    func config(icon: String?, title: String, showLine: Bool) {
        if let ic = icon {
            let img = UIImage(named: ic)
            itemIcon.snp.updateConstraints { (make) in
                make.size.equalTo(img!.size)
                make.left.equalToSuperview().offset(attributes.itemInset.left)
            }
            itemIcon.image = img
            let offsetX = attributes.itemInset.left + attributes.itemPadding
            titleLable.snp.updateConstraints { (make) in
                make.left.equalToSuperview().offset(offsetX + img!.size.width)
            }
        }else {
            titleLable.snp.updateConstraints { (make) in
                make.left.equalToSuperview().offset(attributes.itemInset.left)
            }
        }
        lineView.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(attributes.lineInset.left)
            make.right.equalToSuperview().offset(-attributes.lineInset.right)
        }
        lineView.isHidden = !showLine
        itemIcon.isHidden = icon == nil
        titleLable.text = title
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
    
    /// menuList 弹窗
    /// - Parameters:
    ///   - position: 箭头位置 默认 top
    ///   - origin: 视图位置 (x、y 坐标)
    ///   - imgs: 数据源图标
    ///   - items: 数据源标题
    ///   - offsetX: 箭头顶点相对视图的左偏移量(箭头宽度默认 16pt)
    ///   - highlightedIndex: 凸显的 item 下标 默认都不凸显
    ///   - callback: item 事件回调
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    public func showMenu(
        position: KeenMenuList.ArrowPostion = .top,
        origin: CGPoint,
        imgs: [String]? = nil,
        items: [String],
        offsetX: CGFloat,
        highlightedIndex: Int = -1,
        callback: ((_ index: Int) -> ())?,
        attributes: KeenMenuListAttributes? = nil
    ) {
        let menuList = KeenMenuList(
            position: position,
            origin: origin,
            imgs: imgs,
            items: items,
            offsetX: offsetX,
            highlightedIndex: highlightedIndex,
            callback: callback,
            attributes: attributes
        )
        menuList.show()
    }
}
