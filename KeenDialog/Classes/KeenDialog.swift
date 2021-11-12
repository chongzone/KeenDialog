//
//  KeenDialog.swift
//  KeenDialog
//
//  Created by chongzone on 2021/1/27.
//

import UIKit
import SnapKit

public extension KeenDialog {
    
    /// 弹窗样式
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
}

//MARK: - KeenDialog 类
open class KeenDialog: UIView {
    
    /// 样式 默认 alert
    public var style: KeenDialog.Style = .alert
    
    /// 动画时长 默认 0.3s
    public var duration: Double = 0.3
    /// 是否点击区域外消失  默认 false
    public var isClickDisappear: Bool = false
    /// 是否绑定 Vc  针对页面即将显示时弹窗 默认 false
    public var isBindingPageView: Bool = false
    /// 遮罩背景色 默认 #000000 透明度 40%
    public var maskColor: UIColor = UIColor.color(hexString:"#000000").toColor(of:0.4)
    
    /// 容器视图
    private var container: UIView!
    /// 视图标识
    private static let kDialogIdentifier: Int = LONG_MAX - 100
    
    /// 遮罩 View
    private lazy var masksView: UIControl = {
        let view = UIControl().backColor(maskColor)
        view.addTarget(self, action: #selector(clickMaskAction), for: .touchUpInside)
        return view
    }()
    
    /// 初始化
    public override init(frame: CGRect) {
        super.init(frame: frame)
        tag = KeenDialog.kDialogIdentifier
    }
    
    /// 子控件布局
    open func createSubviews() {
       /// ...
    }
    
    /// 弹窗显示 默认动画
    /// - Parameters:
    ///   - container: 容器视图 若是 nil 则取 UIWindow 视图
    ///   - animated: 是否动画
    public func show(_ container: UIView? = nil, animated: Bool = true) {
        /// 是否存在键盘
        var view: UIWindow?
        var isExitKeyboard = false
        let keyWindow = UIDevice.keyWindow
        for window in UIDevice.windows {
            if "UIRemoteKeyboardWindow" == window.className {
                view = window
                isExitKeyboard = true
                break
            }
        }
        var containView: UIView = isExitKeyboard ? view! : keyWindow!
        if isExitKeyboard, let _ = container { container!.endEditing(true) }
        if let _ = container { containView = container! }
        
        let dialogView = containView.viewWithTag(KeenDialog.kDialogIdentifier)
        if let dialog = dialogView {
            if dialog.className == self.className {
                remove()
            }
        }
        masksView.frame = containView.bounds
        containView.addSubview(masksView)
        self.container = containView
        masksView.addSubview(self)
        
        /// 布局
        createSubviews()
        
        /// 显示
        let topVc = UIViewController.topViewController()
        if let vc = topVc, isBindingPageView == true { vc.viewWillDisappear(true) }
        
        switch style {
        case .alert: alertIn(animated)
        case .actionSheet: actionSheetIn(animated)
        case .drop: dropIn(animated)
        case .menu: menuIn(animated)
        case .toast: toastIn(animated)
        case .hud: hudIn(animated)
        }
        
        if let vc = topVc, isBindingPageView == true { vc.viewDidDisappear(true) }
    }
    
    /// 弹窗消失 默认动画
    /// - Parameters:
    ///   - callback: 弹窗消失回调
    ///   - animated: 是否动画
    public func dismiss(_ callback: (() -> ())? = nil, animated: Bool = true) {
        let topVc = UIViewController.topViewController()
        if let vc = topVc, isBindingPageView == true { vc.viewWillAppear(true) }
        
        switch style {
        case .alert: alertOut(callback, animated: animated)
        case .actionSheet: actionSheetOut(callback, animated: animated)
        case .drop: dropOut(callback, animated: animated)
        case .menu: menuOut(callback, animated: animated)
        case .toast: toastOut(callback, animated: animated)
        case .hud: hudOut(callback, animated: animated)
        }
        
        if let vc = topVc, isBindingPageView == true { vc.viewDidAppear(true) }
    }
    
    /// 弹窗消失 默认动画
    /// - Parameters:
    ///   - container: 容器视图 若是 nil 则取 UIWindow 视图
    ///   - callback: 弹窗消失回调
    ///   - animated: 是否动画
    public static func dismiss(
        _ container: UIView? = nil,
        _ callback: (() -> ())? = nil,
        animated: Bool = true
    ) {
        var view: UIWindow?
        var existView: KeenDialog?
        let keyWindow = UIDevice.keyWindow
        for window in UIDevice.windows {
            if "UIRemoteKeyboardWindow" == window.className {
                view = window
                existView = view!.viewWithTag(KeenDialog.kDialogIdentifier) as? KeenDialog
                break
            }
        }
        if let c = container {
            existView = c.viewWithTag(KeenDialog.kDialogIdentifier) as? KeenDialog
        }else {
            if existView == nil, let w = keyWindow {
                existView = w.viewWithTag(KeenDialog.kDialogIdentifier) as? KeenDialog
            }
        }
        if let e = existView  { e.dismiss(callback, animated: animated) }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - dialog 事件
private extension KeenDialog {
    
    @objc func clickMaskAction() {
        if isClickDisappear {
            dismiss()
        }
    }
    
    func alertIn(_ animated: Bool = true) {
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
        
        let block: ((Bool) -> ()) = { [weak self] fore in
            self?.alpha = fore ? 1.0 : 0.0
            self?.masksView.alpha = fore ? 1.0 : 0.0
            self?.transform = fore ? .identity : CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
        block(false)
        if animated {
            UIView.animate(withDuration: duration) {
                block(true)
            }
        }else {
            block(true)
        }
    }
    
    func alertOut(_ callback:(() -> ())? = nil, animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: duration) {
                self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                self.masksView.alpha = 0.0
                self.alpha = 0.0
            } completion: { (finish) in
                if finish {
                    self.remove(callback)
                }
            }
        }else {
            remove(callback)
        }
    }
    
    func actionSheetIn(_ animated: Bool = true) {
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
        
        var start = frame
        let end = frame
        start.origin.y = container.height
        frame = start
        
        alpha = 1.0
        masksView.alpha = 0.0
        let block: (() -> ()) = { [weak self] in
            self?.frame = end
            self?.masksView.alpha = 1.0
        }
        if animated {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: .transitionFlipFromBottom
            ) {
                block()
            }
        }else {
            block()
        }
    }
    
    func actionSheetOut(_ callback: (() -> ())? = nil, animated: Bool) {
        let start = frame
        let block: (() -> ()) = { [weak self] in
            self?.frame = start
            self?.remove(callback)
        }
        if animated {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: .transitionFlipFromBottom
            ) {
                var end = self.frame
                end.origin.y = self.container.height
                self.frame = end
                self.masksView.alpha = 0.0
            } completion: { (finish) in
                if finish {
                    block()
                }
            }
        }else {
            block()
        }
    }
    
    func dropIn(_ animated: Bool) {
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
        
        var start = frame
        let end = frame
        start.origin.y = -height
        frame = start
        
        alpha = 1.0
        masksView.alpha = 0.0
        let block: (() -> ()) = { [weak self] in
            self?.frame = end
            self?.masksView.alpha = 1.0
        }
        if animated {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 15,
                options: .curveEaseOut
            ) {
                block()
            }
        }else {
            block()
        }
    }
    
    func dropOut(_ callback: (() -> ())? = nil, animated: Bool) {
        let start = frame
        var end = frame
        end.origin.y = -end.height
        let block: (() -> ()) = { [weak self] in
            self?.frame = start
            self?.remove(callback)
        }
        if animated {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: .curveEaseIn
            ) {
                self.frame = end
                self.masksView.alpha = 0.0
            } completion: { (finish) in
                if finish {
                    block()
                }
            }
        }else {
            block()
        }
    }
    
    func menuIn(_ animated: Bool) {
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
        
        alpha = 0.0
        masksView.alpha = 0.0
        transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
        let end = frame
        let block: (() -> ()) = { [weak self] in
            self?.frame = end
            self?.alpha = 1.0
            self?.masksView.alpha = 1.0
            self?.transform = .identity
        }
        if animated {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 15,
                options: .curveEaseOut
            ) {
                block()
            }
        }else {
            block()
        }
    }
    
    func menuOut(_ callback: (() -> ())? = nil, animated: Bool) {
        let start = frame
        let block: (() -> ()) = { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            self?.masksView.alpha = 0.0
            self?.frame = start
            self?.remove(callback)
        }
        if animated {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 15,
                options: .curveEaseOut
            ) {
                block()
            }
        }else {
            block()
        }
    }
    
    func toastIn(_ animated: Bool) {
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
        
        alpha = 1.0
        masksView.alpha = 0.0
        let delay: DispatchTime = .now() + duration
        let block: (() -> ()) = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: delay) {
                UIView.animate(withDuration: 0.25) {
                    self?.masksView.alpha = 0.0
                    self?.alpha = 0
                    self?.remove()
                }
            }
        }
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.masksView.alpha = 1.0
            } completion: { (finish) in
                if finish {
                    block()
                }
            }
        }else {
            block()
        }
    }
    
    func toastOut(_ callback: (() -> ())? = nil, animated: Bool) {
        let block: (() -> ()) = { [weak self] in
            self?.masksView.alpha = 0.0
            self?.alpha = 0
            self?.remove(callback)
        }
        if animated {
            UIView.animate(withDuration: 0.25) {
                block()
            }
        }else {
            block()
        }
    }
    
    func hudIn(_ animated: Bool) {
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
        
        alpha = 1.0
        masksView.alpha = 0.0
        let block: (() -> ()) = { [weak self] in
            self?.masksView.alpha = 1.0
        }
        if animated {
            UIView.animate(withDuration: duration) {
                block()
            }
        }else {
            block()
        }
    }
    
    func hudOut(_ callback: (() -> ())? = nil, animated: Bool) {
        let block: (() -> ()) = { [weak self] in
            self?.masksView.alpha = 0.0
            self?.alpha = 0.0
            self?.remove(callback)
        }
        if animated {
            UIView.animate(withDuration: duration) {
                block()
            }
        }else {
            block()
        }
    }
    
    func remove(_ callback:(() -> ())? = nil) {
        masksView.removeFromSuperview()
        removeFromSuperview()
        if let c = callback {
            c()
        }
    }
}
