//
//  UIPanGestureRecognizer+Extensions.swift
//  
//
//  Created by iferret on 2023/1/18.
//

import UIKit

extension CompatibleWrapper where Base: UIPanGestureRecognizer {
    
    /// Bool
    internal var canSwitch: Bool {
        return !(base is UIScreenEdgePanGestureRecognizer)
    }
    
    /// CGFloat
    internal var xTranslation: CGFloat {
        return base.view?.side.untransformed {
            return base.translation(in: base.view).x
        } ?? 0
    }
    
    /// CGFloat
    internal var xVelocity: CGFloat {
        return base.view?.side.untransformed {
            return base.velocity(in: base.view).x
        } ?? 0
    }
}

