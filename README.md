![KeenDialog](https://raw.githubusercontent.com/chongzone/KeenDialog/master/Resources/KeenDialogLogo.png)

![CI Status](https://img.shields.io/travis/chongzone/KeenDialog.svg?style=flat)
![](https://img.shields.io/badge/swift-5.0%2B-orange.svg?style=flat)
![](https://img.shields.io/badge/pod-v1.0.0-brightgreen.svg?style=flat)
![](https://img.shields.io/badge/platform-iOS10.0%2B-orange.svg?style=flat)
![](https://img.shields.io/badge/license-MIT-blue.svg)

## 效果样式 

样式说明 | Gif 图 |
----|------|
提示警告框 |  <img src="https://raw.githubusercontent.com/chongzone/KeenDialog/master/Resources/dialog_01.gif" width="313" height="478"> |
上拉弹窗 |  <img src="https://raw.githubusercontent.com/chongzone/KeenDialog/master/Resources/dialog_02.gif" width="319" height="390"> |
菜单 |  <img src="https://raw.githubusercontent.com/chongzone/KeenDialog/master/Resources/dialog_03.gif" width="319" height="390"> |
指示器 |  <img src="https://raw.githubusercontent.com/chongzone/KeenDialog/master/Resources/dialog_04.gif" width="319" height="390"> |
日期、地址、吐司 |  <img src="https://raw.githubusercontent.com/chongzone/KeenDialog/master/Resources/dialog_05.gif" width="319" height="319"> |
下拉弹窗 |  <img src="https://raw.githubusercontent.com/chongzone/KeenDialog/master/Resources/dialog_05.gif" width="320" height="502"> |

## API 说明

- [x] 提供 6 种样式的对话框，接入非常方便，对工程业务无侵入，可根据视觉自由定制属性参数 
- [x] 基于 `UILabel`、`UITextView`、`UIPickerView`、`UITableView` 等控件的自定义对话框
- [x] 提醒框内容过多支持滑动显示，支持自定义视图，其中对文本框的键盘弹起期间进行了处理
- [x] 地址选择框提供了默认的全国省份城市数据，三级联动选择，其中数据源支持外部配置
- [x] 指示器加载框提供 2 种样式，若是不满足要求的话，外部支持自定义加载视图
- [x] 菜单框提供 2 种样式吐司框提供 3 种样式，具体可自由配置
- [x] 日期选择框提供 7 中样式，支持各个日期列是否联动

支持的弹窗样式
```ruby
enum Style: Int {
    /// 提醒弹窗
    case alert = 0
    /// 上拉弹窗
    case actionSheet = 1
    /// 下拉弹窗
    case drop = 2
    /// 菜单弹窗
    case menu = 3
    /// 吐司弹窗
    case toast = 4
    /// 指示器弹窗
    case hud = 5
}
```

## 使用介绍

### `KeenAlertMsg` 示例

```ruby
let view = UITextField()
view.backColor(.orange)
var attri = KeenAlertMsgAttributes()
attri.customView = view
attri.customViewHeight = 100
attri.position = .bottom
attri.observerKeyboard = true
showAlert(
    title: "乔巴语录",
    msg: "只要能成为你的力量，我就算变成真正的怪物也在所不惜",
    cancelTitle: "取消",
    doneTitle: "确定",
    callback: { index in
        print("index \(index)")
}, attributes: attri)
```

### `KeenActionSheet` 示例

```ruby
var attri = KeenActionSheetAttributes()
attri.titleHeight = 45
// ...
showActionSheet(
    title: nil,
    items: ["拍摄\n照片或视频", "从手机相册选择", "用剪影制作视频"],
    highlightedIndex: -1,
    cancelTitle: "取消",
    callback: { index in
    print("index \(index)")
}, cancel: {
    print("cancel")
}, attributes: attri)
```

### `KeenDatePicker` 示例

```ruby
var selectValue: String!
// ...
var attri = KeenDatePickerAttributes()
attri.autoRecord = true
// ...
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
```

### `KeenAddressPicker` 示例

```ruby
var attri = KeenAddressPickerAttributes()
attri.autoRecord = true
// ...
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
```

### `KeenMenuList` 示例

```ruby
var selectIndex: Int = -1
// ...
var attri = KeenMenuListAttributes()
attri.highlightedColor = .red
// ...
showMenu(
    position: .top,
    origin: CGPoint(x: 100, y: 150),
    imgs: nil,
    items: ["唐三藏", "孙大圣", "猪八戒", "沙和尚", "如来佛", "观世音"],
    offsetX: 25,
    highlightedIndex: selectIndex,
    callback: { index in
    print("index \(index)")
    self.selectIndex = index
}, attributes: attri)
```

### `KeenToast` 示例

```ruby
var attri = KeenToastAttributes()
attri.viewMargin = 30
// ...
showToast(
    title: "理解 swift 和 swiftUI 的编译方式",
    duration: 2,
    position: .bottom,
    attributes: attri,
    aView: nil
)
```

### `KeenHud` 示例

```ruby
/// 1.
var attri = KeenHudAttributes()
attri.viewRadius = 8
showHud(
    title: "正在加载",
    style: .torus,
    attributes: attri,
    aView: view
)
/// 模拟请求耗时
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {[weak self] in
    self?.dismissHud(self?.view)
}

/// 2.
showHud()
/// 模拟请求耗时
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {[weak self] in
    self?.dismissHud()
}
```

> 具体参数属性等配置可下载查看源码实现 

## 安装方式 

### CocoaPods

```ruby
platform :ios, '10.0'
use_frameworks!

target 'TargetName' do

pod 'KeenDialog'

end
```
> `iOS` 版本要求 `10.0+`
> `Swift` 版本要求 `5.0+`

## Contact Me

QQ: 2209868966
邮箱: chongzone@163.com

> 若在使用过程中遇到什么问题, 请 `issues` 我, 看到之后会尽快修复 

## License

KeenDialog is available under the MIT license. [See the LICENSE](https://github.com/chongzone/KeenDialog/blob/main/LICENSE) file for more info.
