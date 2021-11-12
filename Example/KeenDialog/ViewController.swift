//
//  UITableViewController.swift
//  KeenDialog
//
//  Created by chongzone on 01/27/2021.
//  Copyright (c) 2021 chongzone. All rights reserved.
//

import UIKit
import KeenDialog

class ViewController: UITableViewController {

    var selectValue: String!
    
    var selectIndex: Int = -1
    
    var popView: DropListView!
    
    var province: KeenAddressPickerData?
    var city: KeenAddressPickerData?
    var area: KeenAddressPickerData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "KeenDialog"
        
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "KeenDialog"
        )
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.standardAppearance = appearance
        }else {
            // Fallback on earlier versions
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 20 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeenDialog", for: indexPath)
        switch indexPath.row {
        case 0: cell.textLabel?.text = "alert 弹窗 1"
        case 1: cell.textLabel?.text = "alert 弹窗 2"
        case 2: cell.textLabel?.text = "alert 弹窗 3"
        case 3: cell.textLabel?.text = "alert 弹窗 4"
        case 4: cell.textLabel?.text = "alert 弹窗 5"
        case 5: cell.textLabel?.text = "alert 弹窗 6"
        case 6: cell.textLabel?.text = "alert 弹窗 7"
        case 7: cell.textLabel?.text = "actionSheet 弹窗 1"
        case 8: cell.textLabel?.text = "actionSheet 弹窗 2"
        case 9: cell.textLabel?.text = "actionSheet 弹窗 3"
        case 10: cell.textLabel?.text = "菜单弹窗 1"
        case 11: cell.textLabel?.text = "菜单弹窗 2"
        case 12: cell.textLabel?.text = "hud 加载指示器 1"
        case 13: cell.textLabel?.text = "hud 加载指示器 2"
        case 14: cell.textLabel?.text = "hud 加载指示器 3"
        case 15: cell.textLabel?.text = "日期选择弹窗"
        case 16: cell.textLabel?.text = "地址选择弹窗"
        case 17: cell.textLabel?.text = "toast 指示器"
        case 18: cell.textLabel?.text = "drop 下拉弹窗 1"
        default: cell.textLabel?.text = "drop 下拉弹窗 2"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let idx = indexPath.row
        switch indexPath.row {
        case 0:
            showAlert(msg: "海贼王")
        case 1:
            showAlert(
                title: "海贼王",
                msg: "海贼王已经连载20年",
                callback: { index in
                    print("index \(index)")
                })
        case 2:
            let view = UITextField()
            view.textColor = .white
            view.borderStyle = .roundedRect
            view.placeholder = "自定义视图之文本框"
            var attri = KeenAlertMsgAttributes()
            attri.position = .bottom
            attri.customView = view
            attri.customViewInset = UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 15)
            attri.customViewHeight = 100
            attri.observerKeyboard = true
            showAlert(
                title: "乔巴语录",
                msg: nil,
                callback: { index in
                    print("index \(index)")
            }, attributes: attri)
        case 3, 4, 5, 6:
            let view = UILabel()
            view.textAlignment = .center
            view.backColor(.orange)
            view.textColor = .white
            view.text = "自定义视图"
            var attri = KeenAlertMsgAttributes()
            attri.position = idx == 3 ? .top : (idx == 4 ? .middle : .bottom)
            attri.customView = view
            attri.customViewHeight = 100
            attri.customViewInset = .zero
            attri.msgBottomPadding = 20
            if idx == 6 {
                showAlert(
                    msg: nil,
                    callback: { index in
                    print("index \(index)")
                }, attributes: attri)
            }else {
                showAlert(
                    title: "乔巴语录",
                    msg: "只要能成为你的力量，我就算变成真正的怪物也在所不惜",
                    cancelTitle: "取消",
                    doneTitle: "确定",
                    callback: { index in
                        print("index \(index)")
                }, attributes: attri)
            }
        case 7, 8, 9:
            /// 两行的话 用 '\n' 区分
            var attri = KeenActionSheetAttributes()
            var items = ["拍摄\n照片或视频", "从手机相册选择", "用剪影制作视频"]
            if idx == 8 {
                attri.highlightedColor = .red
                items = ["葫芦", "火影", "海贼王", "西游记"]
            }
            if idx == 9 {
                items = ["葫芦", "火影", "海贼王", "西游记", "四驱兄弟", "喜羊羊", "犬夜叉"]
            }
            showActionSheet(
                title: idx == 9 ? "动画片" : nil,
                items: items,
                highlightedIndex: idx == 8 ? 2 : -1,
                cancelTitle: "取消",
                callback: { index in
                print("index \(index)")
            }, cancel: {
                print("cancel")
            }, attributes: attri)
        case 10, 11:
            var attri = KeenMenuListAttributes()
            let items = ["唐三藏", "孙大圣", "猪八戒", "沙和尚"]
            var offsetY: CGFloat = CGFloat(idx) * 44.0 + .safeAreaTopHeight + 64
            if idx == 11 {
                offsetY = offsetY - CGFloat(items.count * 44) + attri.arrowHeight
            }else {
                offsetY = offsetY + attri.arrowHeight
            }
            attri.highlightedColor = .red
            showMenu(
                position: idx == 10 ? .top : .bottom,
                origin: CGPoint(x: 120, y: offsetY),
                imgs: nil,
                items: items,
                offsetX: 25,
                highlightedIndex: selectIndex,
                callback: { index in
                print("index \(index)")
                self.selectIndex = index
            }, attributes: attri)
        case 12:
            showHud()
            /// 模拟请求耗时
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
                self?.dismissHud()
            }
        case 13:
            showHud(title: "正在提交", style: .torus)
            /// 模拟请求耗时
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
                self?.dismissHud()
            }
        case 14:
            var attri = KeenHudAttributes()
            attri.systemColor = .red
            showHud(
                title: "正在提交",
                style: .system,
                attributes: attri,
                aView: view
            )
            /// 模拟请求耗时
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
                self?.dismissHud(self?.view)
            }
        case 15:
            /// 这里只做 年月日 展示 其他类似
            var attri = KeenDatePickerAttributes()
            attri.autoRecord = true
            showDate(
                mode: .ymd,
                title: "时间选择",
                defaultValue: selectValue,
                minDate: nil,
                maxDate: Date(),
                cancelTitle: "取消",
                doneTitle: "确定",
                callback: { value in
                print("value \(value)")
            }, cancel: {
                print("cancel")
            }, attributes: attri)
        case 16:
            /// 这里地址数据源可定制 具体看源码
            var attri = KeenAddressPickerAttributes()
            attri.autoRecord = true
            showAddress(
                title: "地址选择",
                defaultValue: (self.province, self.city, self.area),
                cancelTitle: "取消",
                doneTitle: "完成",
                callback: { province, city, area in
                print("index \(province.index) \(province.name) \(province.code)")
                print("index \(city.index) \(city.name) \(city.code)")
                print("index \(area.index) \(area.name) \(area.code)")
                self.area = area
                self.city = city
                self.province = province
            }, cancel: {
                print("cancel")
            }, attributes: attri)
        case 17:
            /// 这里只做一种样式展示 其他类似
            var attri = KeenToastAttributes()
            attri.viewMargin = 30
            showToast(
                title: "理解 swift 和 swiftUI 的编译方式",
                duration: 2,
                position: .center,
                attributes: attri,
                aView: nil
            )
        case 18:
            let viewH: CGFloat = 150+100+100
            let rect = CGRect(x: 0, y: 0, width: .screenWidth, height: viewH)
            popView = DropListView(frame: rect, callback: { [weak self] in
                self?.removePopView()
            })
            popView.show()
        default:
            let viewH: CGFloat = 150+100+100
            let viewY: CGFloat = .safeAreaTopHeight + 64
            let rect = CGRect(x: 0, y: viewY, width: .screenWidth, height: viewH)
            popView = DropListView(frame: rect, callback: { [weak self] in
                self?.removePopView()
            })
            popView.show(view, animated: true)
        }
    }
    
    func removePopView() {
        popView.dismiss({
            print("dismiss")
        }, animated: true)
    }
}

//MARK: - 下拉弹窗示例
class DropListView: KeenDialog {
    
    var callback: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, callback: @escaping (() -> ())) {
        self.init(frame: frame)
        self.callback = callback
        self.backColor(.white)
        self.isClickDisappear = true
        self.style = .drop
    }
    
    /// 这里为了展示 利用了 frame 布局 推荐自动布局
    override func createSubviews() {
        
        let label = UILabel(x: 0, y: 0, width: .screenWidth, height: 150)
        label.text = "人有时候是绝对不能逃避战斗的！尤其是当伙伴的梦想被人嘲笑的时候！"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.backgroundColor = .orange
        label.textAlignment = .center
        label.numberOfLines = 0
        addSubview(label)
        
        let view = UILabel(x: 0, y: label.bottom, width: .screenWidth, height: 100)
        view.text = "如果连一个船长都保护不了，还谈什么野心，路飞可是要成为海贼王的男人"
        view.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        view.backgroundColor = .brown
        view.textAlignment = .center
        view.numberOfLines = 0
        addSubview(view)
        
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .cyan
        btn.setTitle("按钮", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.frame = CGRect(x: 100, y: view.bottom, width: .screenWidth - 200, height: 100)
        btn.addTarget(self, action: #selector(clickViewAction), for: .touchUpInside)
        addSubview(btn)
    }
    
    @objc func clickViewAction() {
        if let c = callback {
            c()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
