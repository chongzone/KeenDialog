//
//  KeenDatePicker.swift
//  KeenDialog
//
//  Created by chongzone on 2021/2/26.
//

import UIKit

public extension KeenDatePicker {
    
    enum DateMode: String {
        /// 年月日时分
        case ymdhm = "yyyy-MM-dd HH:mm"
        /// 月日时分
        case mdhm = "MM-dd HH:mm"
        /// 年月日
        case ymd = "yyyy-MM-dd"
        /// 年月
        case ym = "yyyy-MM"
        /// 月日
        case md = "MM-dd"
        /// 时分
        case hm = "HH:mm"
        /// 年
        case y = "yyyy"
    }
    
    private enum DataType: Int {
        /// 年份
        case year
        /// 月份
        case month
        /// 天数
        case day
        /// 小时
        case hour
        /// 分钟
        case minute
    }
}

//MARK: - 属性参数
public struct KeenDatePickerAttributes {
    
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
    /// 日期控件高度 默认 216pt
    public var datePickerHeight: CGFloat = 216
    /// 日期模式 默认 ymd
    public var mode: KeenDatePicker.DateMode = .ymd
    
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
    
    public init() { }
}

//MARK: - KeenDatePicker 类
public class KeenDatePicker: KeenDialog {
    
    /// 属性参数
    private var attributes: KeenDatePickerAttributes = KeenDatePickerAttributes()
    
    /// 总年数
    private var years: Int = 0
    /// 总月数
    private var months: Int = 0
    /// 总天数
    private var days: Int = 0
    /// 总小时
    private var hours: Int = 0
    /// 总分钟
    private var minutes: Int = 0
    /// 最小时间
    private var minDate: Date!
    /// 最大时间
    private var maxDate: Date!
    /// 默认时间
    private var defaultDate: Date!
    /// 数据类型
    private var type: KeenDatePicker.DataType = .year
    
    /// 标题
    private var title: String?
    /// 取消按钮标题
    private var cancelTitle: String?
    /// 确定按钮标题
    private var doneTitle: String?
    /// 点击取消按钮回调
    private var cancelback: (() -> ())?
    /// 点击 item 事件回调
    private var callback: ((_ value: String) -> ())?
    
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
    ///   - mode: 日期模式 默认 .ymd
    ///   - title: 标题
    ///   - defaultValue: 默认选择的日期数据 若为 nil 则取当前日期
    ///   - minDate: 最小日期 为 nil 则取 Date.distantPast
    ///   - maxDate: 最大日期 为 nil 则取 Date.distantFuture
    ///   - cancelTitle: 取消按钮
    ///   - doneTitle: 确定按钮
    ///   - callback: 日期选择事件回调
    ///   - cancel: 取消按钮回调
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    public init(
        mode: KeenDatePicker.DateMode = .ymd,
        title: String? = nil,
        defaultValue: String? = nil,
        minDate: Date? = nil,
        maxDate: Date? = nil,
        cancelTitle: String? = "取消",
        doneTitle: String? = "确定",
        callback: ((_ value: String) -> ())?,
        cancel: (() -> ())? = nil,
        attributes: KeenDatePickerAttributes? = nil
    ) {
        self.title = title
        if let attri = attributes { self.attributes = attri }
        self.attributes.mode = mode
        self.cancelTitle = cancelTitle
        self.doneTitle = doneTitle
        self.cancelback = cancel
        self.callback = callback
        super.init(frame: .zero)
        self.backColor(self.attributes.viewBackColor)
        self.isClickDisappear = true
        self.style = .actionSheet
        
        __config(mode, defaultValue: defaultValue, minDate: minDate, maxDate: maxDate)
    }
    
    private func __config(_ mode: KeenDatePicker.DateMode, defaultValue: String?, minDate: Date?, maxDate: Date?) {
        if let min = minDate {
            self.minDate = min
        }else {
            switch mode {
            case .y, .ym, .ymd, .ymdhm:
                self.minDate = Date.date(of: Date.distantPast, format: mode.rawValue)
            case .mdhm:
                self.minDate = Date.stringToDate("01-01 00:00", format: mode.rawValue)
            case .md:
                self.minDate = Date.stringToDate("01-01", format: mode.rawValue)
            case .hm:
                self.minDate = Date.stringToDate("00:00", format: mode.rawValue)
            }
        }
        if let max = maxDate {
            self.maxDate = max
        }else {
            switch mode {
            case .y, .ym, .ymd, .ymdhm:
                self.maxDate = Date.date(of: Date.distantFuture, format: mode.rawValue)
            case .mdhm:
                self.maxDate = Date.stringToDate("12-31 23:59", format: mode.rawValue)
            case .md:
                self.maxDate = Date.stringToDate("12-31", format: mode.rawValue)
            case .hm:
                self.maxDate = Date.stringToDate("23:59", format: mode.rawValue)
            }
        }
        var flag = self.maxDate.compare(self.minDate) == .orderedAscending
        assert(!flag, "最小日期、最大日期设置错误, 请检查参数值")
        
        if let value = defaultValue {
            defaultDate = Date.stringToDate(value, format: mode.rawValue)
        }else {
            defaultDate = Date.date(of: Date(), format: "yyyy-MM-dd HH:mm")
        }
        flag = self.minDate.compare(defaultDate) == .orderedDescending
        assert(!flag, "默认日期不能小于最小日期, 请检查参数值")
        
        flag = self.maxDate.compare(defaultDate) == .orderedAscending
        assert(!flag, "默认日期不能大于最大日期, 请检查参数值")
        
        if flag == true { return }
        
        /// 年份
        years = self.maxDate.dateYear - self.minDate.dateYear + 1
        /// 月份
        updateDate(.month, y: defaultDate.dateYear)
        /// 天数
        updateDate(.day, y: defaultDate.dateYear, m: months)
        /// 小时
        updateDate(.hour, y: defaultDate.dateYear, m: months, d: days)
        /// 分钟
        updateDate(.minute, y: defaultDate.dateYear, m: months, d: days, h: hours)
    }
    
    public override func createSubviews() {
        createDateSubviews()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - 布局|配置
private extension KeenDatePicker {
    
    /// 布局控件
    func createDateSubviews() {
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
        var viewHeight = attributes.titleHeight + attributes.datePickerHeight
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
        
        scrollPicker(to: defaultDate)
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
            if let call = self?.callback {
                let property = self?.finalDateValue()
                call(property!)
            }
        }, animated: true)
    }
}

//MARK: - 业务功能
private extension KeenDatePicker {
    
    /// 滚动到指定日期
    func scrollPicker(to date: Date) {
        let yearIndex = defaultDate.dateYear - minDate.dateYear
        let monthIndex = defaultDate.dateMonth - 1
        let dayIndex = defaultDate.dateDay - 1
        let hourIdx = defaultDate.dateHour
        let minuteIdx = defaultDate.dateMinute
        
        var indexs: Array = [Int]()
        switch attributes.mode {
        case .y: indexs.append([yearIndex])
        case .ym: indexs.append([yearIndex, monthIndex])
        case .md: indexs.append([monthIndex, dayIndex])
        case .hm: indexs.append([hourIdx, minuteIdx])
        case .ymd: indexs.append([yearIndex, monthIndex, dayIndex])
        case .mdhm: indexs.append([monthIndex, dayIndex, hourIdx, minuteIdx])
        case .ymdhm: indexs.append([yearIndex, monthIndex, dayIndex, hourIdx, minuteIdx])
        }
        for idx in 0..<indexs.count {
            pickerView.selectRow(indexs[idx], inComponent: idx, animated: false)
        }
    }
    
    /// 更新日期数据
    private func updateDate(
        _ type: KeenDatePicker.DataType,
        y year: Int = Date().dateYear,
        m month: Int = Date().dateMonth,
        d day: Int = Date().dateDay,
        h hour: Int = Date().dateHour
    ) {
        switch type {
        case .month:
            var start = 1, end = 12
            if minDate.dateYear == year { start = minDate.dateMonth }
            if maxDate.dateYear == year { end = maxDate.dateMonth }
            months = end - start + 1
        case .day:
            var start = 1, end = totalDays(in: year, at: month)
            let block: ((Date) -> Bool) = { date in
                return date.dateYear == year && date.dateMonth == month
            }
            if block(minDate) { start = minDate.dateDay }
            if block(maxDate) { end = maxDate.dateDay }
            days = end - start + 1
        case .hour:
            var start = 0, end = 23
            let block: ((Date) -> Bool) = { date in
                return date.dateYear==year && date.dateMonth==month && date.dateDay==day
            }
            if block(minDate) { start = minDate.dateHour }
            if block(maxDate) { end = maxDate.dateHour }
            hours = end - start
        case .minute:
            var start = 0, end = 59
            let block: ((Date) -> Bool) = { date in
                return date.dateYear == year && date.dateMonth == month && date.dateDay == day && date.dateHour == hour
            }
            if block(minDate) { start = minDate.dateMinute }
            if block(maxDate) { end = maxDate.dateMinute }
            minutes = end - start
        default: break
        }
    }
    
    /// 月份对应的天数
    func totalDays(in year: Int, at month: Int) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        let date = calendar.date(from: components)
        let seconds = TimeZone.current.secondsFromGMT(for: date!)
        let day = date!.addingTimeInterval(TimeInterval(seconds))
        let range = calendar.range(of: .day, in: .month, for: day)
        return range?.count ?? 0
    }
    
    /// 回调日期数据
    func finalDateValue() -> String {
        var result = ""
        switch attributes.mode {
        case .y: result = "\(pickerView.selectedRow(inComponent: 0) + minDate.dateYear)"
        case .ym:
            let year = pickerView.selectedRow(inComponent: 0) + minDate.dateYear
            let month = pickerView.selectedRow(inComponent: 1) + 1
            result = "\(year)" + "-\(month)"
        case .md:
            let month = pickerView.selectedRow(inComponent: 0) + 1
            let day = pickerView.selectedRow(inComponent: 1) + 1
            result = "\(month)" + "-\(day)"
        case .hm:
            let hour = pickerView.selectedRow(inComponent: 0)
            let minute = pickerView.selectedRow(inComponent: 1)
            result = "\(hour)" + ":\(minute)"
        case .ymd:
            let year = pickerView.selectedRow(inComponent: 0) + minDate.dateYear
            let month = pickerView.selectedRow(inComponent: 1) + 1
            let day = pickerView.selectedRow(inComponent: 2) + 1
            result = "\(year)" + "-\(month)" + "-\(day)"
        case .mdhm:
            let month = pickerView.selectedRow(inComponent: 0) + 1
            let day = pickerView.selectedRow(inComponent: 1) + 1
            let hour = pickerView.selectedRow(inComponent: 2)
            let minute = pickerView.selectedRow(inComponent: 3)
            result = "\(month)" + "-\(day)" + " \(hour)" + ":\(minute)"
        case .ymdhm:
            let year = pickerView.selectedRow(inComponent: 0) + minDate.dateYear
            let month = pickerView.selectedRow(inComponent: 1) + 1
            let day = pickerView.selectedRow(inComponent: 2) + 1
            let hour = pickerView.selectedRow(inComponent: 3)
            let minute = pickerView.selectedRow(inComponent: 4)
            result = "\(year)" + "-\(month)" + "-\(day)" + " \(hour)" + ":\(minute)"
        }
        return result
    }
}

//MARK: - UIPickerViewDataSource 数据源
extension KeenDatePicker: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch attributes.mode {
        case .y: return 1
        case .hm, .md, .ym: return 2
        case .ymd: return 3
        case .mdhm: return 4
        case .ymdhm: return 5
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch attributes.mode {
        case .y: return years
        case .ym: return [years, months][component]
        case .ymd: return [years, months, days][component]
        case .ymdhm: return [years, months, days, hours+1, minutes+1][component]
        case .hm: return [hours, minutes][component]
        case .md: return [months, days][component]
        case .mdhm: return [months, days, hours, minutes][component]
        }
    }
}

//MARK: - UIPickerViewDelegate 代理
extension KeenDatePicker: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var text: String = ""
        let minYear = minDate.dateYear
        switch attributes.mode {
        case .y: text = "\(row+minYear)年"
        case .ym: text = ["\(row+minYear)年", "\(row+1)月"][component]
        case .md: text = ["\(row+1)月", "\(row+1)日"][component]
        case .hm: text = ["\(row)时", "\(row)分"][component]
        case .ymd: text = ["\(row+minYear)年", "\(row+1)月", "\(row+1)日"][component]
        case .mdhm: text = ["\(row+1)月", "\(row+1)日", "\(row)时", "\(row)分"][component]
        case .ymdhm: text = ["\(row+minYear)年", "\(row+1)月", "\(row+1)日", "\(row)时", "\(row)分","\(row)秒"][component]
        }
        return UILabel()
            .backColor(attributes.itemBackColor)
            .textColor(attributes.itemColor)
            .font(attributes.itemFont)
            .lineMode(.byTruncatingTail)
            .alignment(.center)
            .numberOfLines(0)
            .text(text)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let year = pickerView.selectedRow(inComponent: 0) + minDate.dateYear
        let month = pickerView.selectedRow(inComponent: 1) + 1
        switch attributes.mode {
        case .ym:
            switch component {
            case 0:
                updateDate(.month, y: year)
                pickerView.reloadComponent(1)
            default: break
            }
        case .md:
            let month = pickerView.selectedRow(inComponent: 0) + 1
            switch component {
            case 0:
                updateDate(.day, m: min(month, months))
                pickerView.reloadComponent(1)
            default: break
            }
        case .hm:
            let hour = pickerView.selectedRow(inComponent: 0)
            switch component {
            case 0:
                updateDate(.minute, h: min(hour, hours))
                pickerView.reloadComponent(1)
            default: break
            }
        case .ymd:
            switch component {
            case 0:
                updateDate(.month, y: year)
                updateDate(.day, y: year, m: min(month, months))
                pickerView.reloadComponent(1)
                pickerView.reloadComponent(2)
            case 1:
                updateDate(.day, y: year, m: min(month, months))
                pickerView.reloadComponent(2)
            default: break
            }
        case .mdhm:
            let month = pickerView.selectedRow(inComponent: 0) + 1
            let day = pickerView.selectedRow(inComponent: 1) + 1
            let hour = pickerView.selectedRow(inComponent: 2)
            switch (component) {
            case 0:
                let m = min(month, months)
                updateDate(.day, m: m)
                updateDate(.hour, m: m, d: min(day, days))
                updateDate(.minute, m: m, d: min(day, days), h: min(hour, hours))
                pickerView.reloadComponent(1)
                pickerView.reloadComponent(2)
                pickerView.reloadComponent(3)
            case 1:
                let m = min(month, months)
                updateDate(.hour, m: m, d: min(day, days))
                updateDate(.minute, m: m, d: min(day, days), h: min(hour, hours))
                pickerView.reloadComponent(2)
                pickerView.reloadComponent(3)
            case 2:
                let m = min(month, months)
                updateDate(.minute, m: m, d: min(day, days), h: min(hour, hours))
                pickerView.reloadComponent(3)
            default: break
            }
        case .ymdhm:
            let day = pickerView.selectedRow(inComponent: 2) + 1
            let hour = pickerView.selectedRow(inComponent: 3)
            switch (component) {
            case 0:
                updateDate(.month, y: year)
                
                let m = min(month, months)
                updateDate(.day, y: year, m: m)
                updateDate(.hour, y: year, m: m, d: min(day, days))
                updateDate(.minute, y: year, m: m, d: min(day,days), h:min(hour,hours))
                pickerView.reloadComponent(1)
                pickerView.reloadComponent(2)
                pickerView.reloadComponent(3)
                pickerView.reloadComponent(4)
            case 1:
                let m = min(month, months)
                updateDate(.day, y: year, m: m)
                updateDate(.hour, y: year, m: m, d: min(day, days))
                updateDate(.minute, y: year, m: m, d: min(day, days), h:min(hour,hours))
                pickerView.reloadComponent(2)
                pickerView.reloadComponent(3)
                pickerView.reloadComponent(4)
            case 2:
                let m = min(month, months)
                updateDate(.hour, y: year, m: m, d: min(day, days))
                updateDate(.minute, y: year, m: m, d: min(day, days), h:min(hour,hours))
                pickerView.reloadComponent(3)
                pickerView.reloadComponent(4)
            case 3:
                let m = min(month, months)
                updateDate(.minute, y: year, m: m, d: min(day, days), h:min(hour,hours))
                pickerView.reloadComponent(4)
                default: break
            }
        default: break
        }
        
        if let auto = callback, attributes.autoRecord == true {
            auto(finalDateValue())
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return attributes.itemHeight
    }
}

//MARK: - 弹窗扩展
extension NSObject {
    
    /// datePicker 弹窗
    /// - Parameters:
    ///   - mode: 日期模式 默认 .ymd
    ///   - title: 标题
    ///   - defaultValue: 默认选择的日期数据 若为 nil 则取当前日期
    ///   - minDate: 最小日期 为 nil 则取 Date.distantPast
    ///   - maxDate: 最大日期 为 nil 则取 Date.distantFuture
    ///   - cancelTitle: 取消按钮
    ///   - doneTitle: 确定按钮
    ///   - callback: 日期选择事件回调
    ///   - cancel: 取消按钮回调
    ///   - attributes: 属性配置 为 nil 取其默认值 具体属性可单独配置
    public func showDate(
        mode: KeenDatePicker.DateMode = .ymd,
        title: String? = nil,
        defaultValue: String?,
        minDate: Date? = nil,
        maxDate: Date? = nil,
        cancelTitle: String? = "取消",
        doneTitle: String? = "确定",
        callback: ((_ value: String) -> ())?,
        cancel: (() -> ())? = nil,
        attributes: KeenDatePickerAttributes? = nil
    ) {
        let datePicker = KeenDatePicker(
            mode: mode,
            title: title,
            defaultValue: defaultValue,
            minDate: minDate,
            maxDate: maxDate,
            cancelTitle: cancelTitle,
            doneTitle: doneTitle,
            callback: callback,
            cancel: cancel,
            attributes: attributes
        )
        datePicker.show()
    }
}
