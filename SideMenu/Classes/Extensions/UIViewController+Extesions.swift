//
//  UIViewController+Extensions.swift
//  
//
//  Created by iferret on 2023/1/18.
//

import UIKit

extension UIViewController: Compatible {}
extension CompatibleWrapper where Base: UIViewController {
    
    /// View controller actively displayed in that layer. It may not be visible if it's presenting another view controller.
    internal var activeViewController: UIViewController {
        switch base {
        case let navigationController as UINavigationController:
            return navigationController.topViewController?.side.activeViewController ?? base
        case let tabBarController as UITabBarController:
            return tabBarController.selectedViewController?.side.activeViewController ?? base
        case let splitViewController as UISplitViewController:
            return splitViewController.viewControllers.last?.side.activeViewController ?? base
        default:
            return base
        }
    }
    
    /// View controller being displayed on screen to the user.
    internal var topMostViewController: UIViewController {
        let activeViewController = base.side.activeViewController
        return activeViewController.presentedViewController?.side.topMostViewController ?? activeViewController
    }
    
    /// UIViewController
    internal var containerViewController: UIViewController {
        if let vc = base.navigationController?.side.containerViewController {
            return vc
        } else if let vc = base.tabBarController?.side.containerViewController {
            return vc
        } else if let vc = base.splitViewController?.side.containerViewController {
            return vc
        } else {
            return base
        }
    }
    
    /// Bool
    internal var isHidden: Bool {
        return base.presentingViewController == nil
    }

    
}
