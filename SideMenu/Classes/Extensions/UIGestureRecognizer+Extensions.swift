//
//  UIGestureRecognizer+Extensions.swift
//  
//
//  Created by iferret on 2023/1/18.
//

import UIKit

extension UIGestureRecognizer {
    
    /// 构建
    /// - Parameters:
    ///   - view: UIView
    ///   - target: Any
    ///   - action: Selector
    internal convenience init(addTo view: UIView, target: Any, action: Selector) {
        self.init(target: target, action: action)
        view.addGestureRecognizer(self)
    }
    
    /// 构建
    /// - Parameters:
    ///   - view: UIView
    ///   - target: Any
    ///   - action: Selector
    internal convenience init?(addTo view: UIView?, target: Any, action: Selector) {
        guard let view = view else { return nil }
        self.init(addTo: view, target: target, action: action)
    }
}

extension UIGestureRecognizer: Compatible {}
extension CompatibleWrapper where Base: UIGestureRecognizer {
    
    /// remove
    internal func remove() {
        base.view?.removeGestureRecognizer(base)
    }
}

