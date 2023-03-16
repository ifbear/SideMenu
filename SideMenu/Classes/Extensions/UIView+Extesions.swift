//
//  UIView+Extesions.swift
//  
//
//  Created by iferret on 2023/1/18.
//

import UIKit

extension UIView {
    
    /// animationsEnabled
    /// - Parameters:
    ///   - enabled: Bool
    ///   - block: Void
    internal static func animationsEnabled(_ enabled: Bool = true, _ block: () -> Void) {
        let a = areAnimationsEnabled
        setAnimationsEnabled(enabled)
        block()
        setAnimationsEnabled(a)
    }
}

extension UIView: Compatible { }
extension CompatibleWrapper where Base: UIView {
    
    /// untransformed
    /// - Parameter block: block: () -> CGFloat
    /// - Returns: CGFloat
    @discardableResult
    internal func untransformed(_ block: () -> CGFloat) -> CGFloat {
        let t = base.transform
        base.transform = .identity
        let value = block()
        base.transform = t
        return value
    }
    
    /// bringToFront
    internal func bringToFront() {
        base.superview?.bringSubviewToFront(base)
    }
    
    /// untransform
    /// - Parameter block: () -> Void
    internal func untransform(_ block: () -> Void) {
        base.side.untransformed { () -> CGFloat in
            block()
            return 0
        }
    }
    
}
