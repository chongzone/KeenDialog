//
//  KeenAddressPicker.swift
//  KeenDialog
//
//  Created by chongzone on 2021/2/28.
//

import UIKit

//MARK: - 属性参数
public struct KeenAddressPickerAttributes {
    
    /// 视图圆角 默认 8pt
    public var viewRadius: CGFloat = 8
    /// 视图背景色 默认 #FFFFFF
    public var viewBackColor: UIColor = UIColor.color(hexString: "#FFFFFF")
    
    /// 标题高度 默认 40pt
    public var titleHeight: CGFloat = 40
    /// 标题颜色 默认 #333333
    public var titleColor: UIColor = UIColor.color(hexString: "#333333")
    /// 标题字体 默认常规 16pt
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    
    /// 选择结束是否自动记录数据 默认 false
    public var autoRecord: Bool = false
    /// 地址控件高度 默认 216pt
    public var addressPickerHeight: CGFloat = 216
    
    /// item 高度 默认 45pt
    public var itemHeight: CGFloat = 45
    /// item 标题颜色 默认 #333333
    public var itemColor: UIColor = UIColor.color(hexString: "#333333")
    /// item 标题字体 默认常规 16pt
    public var itemFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    /// item 背景色 默认 #FFFFFF
    public var itemBackColor: UIColor = UIColor.color(hexString: "#FFFFFF")
    
    /// 取消按钮颜色 默认 #969696
    public var cancelColor: UIColor = UIColor.color(hexString: "#969696")
    /// 取消按钮字体 默认常规 15pt
    public var cancelFont: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    /// 确定按钮颜色 默认 #326FFD
    public var doneColor: UIColor = UIColor.color(hexString: "#326FFD")
    /// 确定按钮字体 默认常规 15pt
    public var doneFont: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    
    /// 分割线条的颜色 默认 #EFEFEF
    public var lineColor: UIColor = UIColor.color(hexString: "#EFEFEF")
    
    /// 省份数据源 外部可替换
    public var dataSourceOfProvince: [[String: Any]] = Bundle.fileResouce(
        of: KeenDialog.self,
        bundle: "KeenDialog",
        name: "address"
    ) as! [[String: Any]]
    /// 城市数据源对应的 key 默认 n
    public var dataSourceKeyOfCity: String = "n"
    /// 县级市区数据源对应的 key 默认 n
    public var dataSourceKeyOfArea: String = "n"
    /// 省份名称对应的 key 默认 v
    public var keyOfProvinceValue: String = "v"
    /// 省份编码对应的 key 默认 k
    public var keyOfProvinceCode: String = "k"
    /// 城市名称对应的 key 默认 v
    public var keyOfCityValue: String = "v"
    /// 城市编码对应的 key 默认 k
    public var keyOfCityCode: String = "k"
    /// 县级市区名称对应的 key 默认 v
    public var keyOfAreaValue: String = "v"
    /// 县级市区编码对应的 key 默认 k
    public var keyOfAreaCode: String = "k"
    
    public init() { }
}

//MARK: - 地址数据模型
public typealias Object = KeenAddressPickerData

public struct KeenAddressPickerData {
    /// 索引
    public var index: Int = 0
    /// 名称
    public var name: String = ""
    /// 编码
    public var code: String = ""
    
    public init() { }
}

//MARK: - KeenAddressPicker 类
public class KeenAddressPicker: KeenDialog {
    
    /// 属性参数
    private var attributes: KeenAddressPickerAttributes = KeenAddressPickerAttributes()
    
    /// 省份数据
    private var provinces: [[String: Any]]!
    /// 城市数据
    private var cities: [[String: Any]]!
    /// 县级市区数据
    private var areas: [[String: String]]!
    
    /// 城市数据源对应的 key
    private var dataSourceKeyOfCity: String!
    /// 县级市区数据源对应的 key
    private var dataSourceKeyOfArea: String!
    /// 省份名称对应的 key
    private var keyOfProvinceValue: String!
    /// 省份编码对应的 key
    private var keyOfProvinceCode: String!
    /// 城市名称对应的 key
    private var keyOfCityValue: String!
    /// 城市编码对应的 key
    private var keyOfCityCode: String!
    /// 县级市区名称对应的 key
    private var keyOfAreaValue: String!
    /// 县级市区编码对应的 key
    private var keyOfAreaCode: String!
    
    /// 省份对象
    private var provinceObject: Object = Object()
    /// 城市对象
    private var cityObject: Object = Object()
    /// 县级市区对象
    private var areaObject: Object = Object()
    
    /// 标题
    private var title: String?
    /// 取消按钮标题
    private var cancelTitle: String?
    /// 确定按钮标题
    private var doneTitle: String?
    /// 点击取消按钮回调
    private var cancelback: (() -> ())?
    /// 点击 item 事件回调
    private var callback:((_ province: Object, _ city: Object, _ area: Object) -> ())?
    
    private lazy var pickerView: UIPickerView = {
        let view = UIPickerView(frame: .zero)
            .dataSource(self)
            .delegate(self)
            .backColor(attributes.viewBackColor)
        return view
    }()
    
    deinit {
        pickerView.dataSource = nil
        pickerView.delegate = nil
    }
    
    /// 初始化
    /// - Parameters:
    ///   - title: 标题
    ///   - defaultValue: 默认选择的地址对象  若皆为 nil 则取其首个地址
    ///   - cancelTitle: 取消按钮
    ///   - doneTitle: 确定按钮
    ///   - callback: 地址选择事件回调
    ///   - cancel: 取消按钮回调
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    public init(
        title: String? = nil,
        defaultValue: (province: Object?, city: Object?, area: Object?)?,
        cancelTitle: String? = "取消",
        doneTitle: String? = "确定",
        callback: ((_ province: Object, _ city: Object, _ area: Object) -> ())?,
        cancel: (() -> ())? = nil,
        attributes: KeenAddressPickerAttributes? = nil
    ) {
        self.title = title
        if let attri = attributes { self.attributes = attri }
        if let addressValue = defaultValue {
            if let value = addressValue.province { self.provinceObject = value }
            if let value = addressValue.city { self.cityObject = value }
            if let value = addressValue.area { self.areaObject = value }
        }
        self.cancelTitle = cancelTitle
        self.doneTitle = doneTitle
        self.cancelback = cancel
        self.callback = callback
        super.init(frame: .zero)
        self.backColor(self.attributes.viewBackColor)
        self.isClickDisappear = true
        self.style = .actionSheet
        
        __config(attributes: self.attributes)
    }
    
    private func __config(attributes: KeenAddressPickerAttributes) {
        dataSourceKeyOfCity = attributes.dataSourceKeyOfCity
        dataSourceKeyOfArea = attributes.dataSourceKeyOfArea
        provinces           = attributes.dataSourceOfProvince
        keyOfProvinceValue  = attributes.keyOfProvinceValue
        keyOfCityValue      = attributes.keyOfCityValue
        keyOfAreaValue      = attributes.keyOfAreaValue
        keyOfProvinceCode   = attributes.keyOfProvinceCode
        keyOfCityCode       = attributes.keyOfCityCode
        keyOfAreaCode       = attributes.keyOfAreaCode
        
        var flag: Bool = provinces.count > 0
        assert(flag, "地址数据为空, 请检查参数值")
        
        let province = provinces.randomElement()!
        
        flag = province.contains(keyOfProvinceCode)
        assert(flag, "地址数据格式不正确, 请检查省份编码对应的 key")
        
        flag = province.contains(keyOfProvinceValue) && province.contains(dataSourceKeyOfCity)
        assert(flag, "地址数据格式不正确, 请检查省份名称对应的 key、城市数据源对应的 key")
        
        flag = province[dataSourceKeyOfCity] is [Any]
        assert(flag, "地址数据格式不正确, 请检查城市数据格式是否为Array")
        
        let cities = province[dataSourceKeyOfCity] as? [Any]
        if let city = cities, city.count > 0 {
            flag = city.randomElement()! is [String: Any]
        }else {
            flag = false
        }
        assert(flag, "地址数据格式不正确, 请检查城市的具体数据格式是否为JSON")
        
        let city = cities!.randomElement()! as! [String: Any]
        
        flag = province.contains(keyOfCityCode)
        assert(flag, "地址数据格式不正确, 请检查城市编码对应的 key")
        
        flag = city.contains(keyOfCityValue) && province.contains(dataSourceKeyOfArea)
        assert(flag, "地址数据格式不正确, 请检查城市名称对应的 key、县级市区数据源对应的 key")
        
        flag = city[dataSourceKeyOfArea] is [Any]
        assert(flag, "地址数据格式不正确, 请检查县级市区数据格式是否为Array")
        
        let areas = city[dataSourceKeyOfArea] as? [Any]
        if let area = areas, area.count > 0 {
            flag = area.randomElement()! is [String: String]
        }else {
            flag = false
        }
        assert(flag, "地址数据格式不正确, 请检查县级市区的具体数据格式是否为JSON")
        
        let area = areas!.randomElement()! as! [String: String]
        
        flag = province.contains(keyOfAreaCode)
        assert(flag, "地址数据格式不正确, 请检查县级市区编码对应的 key")
        
        flag = area.contains(keyOfAreaValue)
        assert(flag, "地址数据格式不正确, 请检查县级市区名称对应的 key")
        
        if flag == false { return }
        
        /// 城市数据
        self.cities = provinces[self.provinceObject.index][dataSourceKeyOfCity]
        /// 县级市区数据
        self.areas = self.cities[self.cityObject.index][dataSourceKeyOfArea]
    }
    
    public override func createSubviews() {
        createAddressSubviews()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - 布局|配置
private extension KeenAddressPicker {
    
    /// 布局控件
    func createAddressSubviews() {
        let titleExist: Bool = title != nil && !title!.isEmpty
        
        /// 标题
        var labelW: CGFloat = 0.0
        if titleExist {
            let label = UILabel()
                .textColor(attributes.titleColor)
                .font(attributes.titleFont)
                .lineMode(.byTruncatingTail)
                .alignment(.center)
                .backColor(attributes.viewBackColor)
                .numberOfLines(0)
                .text(title!)
                .addViewTo(self)
            labelW = title!.calculateSize(
                font: attributes.titleFont,
                width: .greatestFiniteMagnitude,
                height: attributes.titleHeight
            ).width
            label.snp.makeConstraints { (make) in
                make.height.equalTo(attributes.titleHeight)
                make.centerX.equalTo(self.snp.centerX)
                make.top.equalToSuperview()
                make.width.equalTo(labelW)
            }
        }
        
        /// 取消按钮
        var offsetX = titleExist ? -10-labelW*0.5 : -10
        let cancelItem = UIButton(type: .custom)
            .titleEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            .titleColor(attributes.cancelColor, .normal, .highlighted)
            .backColor(.white, .normal, .highlighted)
            .horizontalAlignment(.left)
            .font(attributes.cancelFont)
            .title(cancelTitle)
            .addViewTo(self)
        cancelItem.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.centerX).offset(offsetX)
            make.height.equalTo(attributes.titleHeight)
            make.top.left.equalToSuperview()
        }
        cancelItem.addTarget(
            self,
            action: #selector(clickCancelEvent(sender:)),
            for: .touchUpInside
        )
        
        /// 确定按钮
        offsetX = titleExist ? 10+labelW*0.5 : 10
        let doneItem = UIButton(type: .custom)
            .titleEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
            .titleColor(attributes.doneColor, .normal, .highlighted)
            .backColor(.white, .normal, .highlighted)
            .horizontalAlignment(.right)
            .font(attributes.doneFont)
            .title(doneTitle)
            .addViewTo(self)
        doneItem.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX).offset(offsetX)
            make.height.equalTo(attributes.titleHeight)
            make.top.right.equalToSuperview()
        }
        doneItem.addTarget(
            self,
            action: #selector(clickDoneEvent(sender:)),
            for: .touchUpInside
        )
        
        /// 横线
        UIView()
            .backColor(attributes.lineColor)
            .addViewTo(self)
            .snp.makeConstraints { make in
                make.top.equalToSuperview().offset(attributes.titleHeight-0.5)
                make.left.right.equalToSuperview()
                make.height.equalTo(0.5)
            }
        
        /// 视图
        var viewHeight = attributes.titleHeight + attributes.addressPickerHeight
        viewHeight += CGFloat.safeAreaBottomHeight
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
        
        /// 日期
        pickerView.addViewTo(self)
            .snp.makeConstraints { make in
                make.top.equalToSuperview().offset(attributes.titleHeight)
                make.left.right.bottom.equalToSuperview()
            }
        scrollPicker(
            at: provinceObject.index,
            cityIndex: cityObject.index,
            areaIndex: areaObject.index
        )
    }
    
    /// 取消事件
    @objc func clickCancelEvent(sender: UIButton) {
        dismiss({ [weak self] in
            if let c = self?.cancelback {
                c()
            }
        }, animated: true)
    }
    
    /// 确定事件
    @objc func clickDoneEvent(sender: UIButton) {
        dismiss({ [weak self] in
            if let c = self?.callback {
                let property = self?.finalDateValue()
                c(property!.province, property!.city, property!.area)
            }
        }, animated: true)
    }
}

//MARK: - 业务功能
private extension KeenAddressPicker {
    
    /// 滚动到指定地址
    func scrollPicker(at provinceIndex: Int, cityIndex: Int, areaIndex: Int) {
        switch provinceIndex {
        case 0:
            cities = provinces.first![dataSourceKeyOfCity]
            areas = cities.first![dataSourceKeyOfArea]
        default:
            let flag: Bool = provinces.count > provinceIndex
            assert(flag, "省份下标值已越界, 请检查参数值")
            if flag == false { return }
            
            cities = provinces[provinceIndex][dataSourceKeyOfCity]
            areas = cities[cityIndex][dataSourceKeyOfArea]
        }
        let indexs: Array<Int> = [provinceIndex, cityIndex, areaIndex]
        for idx in 0..<indexs.count {
            if idx == 0 { pickerView.reloadComponent(1) }
            if idx == 0 || idx == 1 { pickerView.reloadComponent(2) }
            pickerView.selectRow(indexs[idx], inComponent: idx, animated: false)
        }
    }

    /// 回调已选择的地址数据
    func finalDateValue() -> (province: Object, city: Object, area: Object) {
        return (provinceObject, cityObject, areaObject)
    }
}

//MARK: - UIPickerViewDataSource 数据源
extension KeenAddressPicker: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int { return 3 }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return provinces.count
        case 1: return cities.count
        case 2: return areas.count
        default: return 0
        }
    }
}

//MARK: - UIPickerViewDelegate 代理
extension KeenAddressPicker: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return provinces[row][keyOfProvinceValue]
        case 1: return cities[row][keyOfCityValue]
        case 2: return areas[row][keyOfAreaValue]
        default: return nil
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        if let t = text {
            return UILabel()
                .backColor(attributes.itemBackColor)
                .textColor(attributes.itemColor)
                .font(attributes.itemFont)
                .lineMode(.byTruncatingTail)
                .alignment(.center)
                .numberOfLines(0)
                .text(t)
        }else {
            return UIView()
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            cities = provinces[row][dataSourceKeyOfCity]
            areas = cities.first![dataSourceKeyOfArea]
            provinceObject.index = row
            cityObject.index = 0
            areaObject.index = 0
            
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 2, animated: true)
        case 1:
            areas = cities[row][dataSourceKeyOfArea]
            cityObject.index = row
            areaObject.index = 0
            
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 2, animated: true)
        case 2: areaObject.index = row
        default: break
        }
        /// 省份
        let provinceIndex    = provinceObject.index
        provinceObject.code  = provinces[provinceIndex][keyOfProvinceCode]!
        provinceObject.name  = provinces[provinceIndex][keyOfProvinceValue]!
        /// 城市
        let cityIndex    = cityObject.index
        cityObject.code  = cities[cityIndex][keyOfCityCode]!
        cityObject.name  = cities[cityIndex][keyOfCityValue]!
        /// 县级市区
        let areaIndex    = areaObject.index
        areaObject.code  = areas[areaIndex][keyOfAreaCode]!
        areaObject.name  = areas[areaIndex][keyOfAreaValue]!
        
        if let auto = callback, attributes.autoRecord == true {
            auto(provinceObject, cityObject, areaObject)
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return attributes.itemHeight
    }
}

//MARK: - 弹窗扩展
extension NSObject {
    
    /// address 弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - defaultValue: 默认选择的地址对象  若皆为 nil 则取其首个地址
    ///   - cancelTitle: 取消按钮
    ///   - doneTitle: 确定按钮
    ///   - callback: 地址选择事件回调
    ///   - cancel: 取消按钮回调
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    public func showAddress(
        title: String? = nil,
        defaultValue: (province: Object?, city: Object?, area: Object?)?,
        cancelTitle: String? = "取消",
        doneTitle: String? = "确定",
        callback: ((_ province: Object, _ city: Object, _ area: Object) -> ())?,
        cancel: (() -> ())? = nil,
        attributes: KeenAddressPickerAttributes? = nil
    ) {
        let addressPicker = KeenAddressPicker(
            title: title,
            defaultValue: defaultValue,
            cancelTitle: cancelTitle,
            doneTitle: doneTitle,
            callback: callback,
            cancel: cancel,
            attributes: attributes
        )
        addressPicker.show()
    }
}
