//
//  UIApplication+Extensions.swift
//  
//
//  Created by iferret on 2023/1/18.
//

import UIKit

extension UIApplication: Compatible {}
extension CompatibleWrapper where Base: UIApplication {
    
    /// UIWindow
    internal var keyWindow: UIWindow? {
        if #available(iOS 15.0, *) {
            let scens: [UIWindowScene] = base.connectedScenes.compactMap { $0 as? UIWindowScene }
            return scens.first(where: { $0.activationState == .foregroundActive })?.keyWindow
        } else if #available(iOS 13.0, *) {
            return base.windows.filter { $0.isKeyWindow }.first
        } else {
            return base.keyWindow
        }
    }
}
