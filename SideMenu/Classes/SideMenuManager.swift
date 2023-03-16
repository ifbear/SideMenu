//
//  SideMenuManager.swift
//
//  Created by Jon Kent on 12/6/15.
//  Copyright © 2015 Jon Kent. All rights reserved.
//

import UIKit

@objcMembers
public class SideMenuManager: NSObject {
    
    /// SideMenuPanGestureRecognizer
    final private class SideMenuPanGestureRecognizer: UIPanGestureRecognizer {}
    /// SideMenuScreenEdgeGestureRecognizer
    final private class SideMenuScreenEdgeGestureRecognizer: UIScreenEdgePanGestureRecognizer {}
    
    /// PresentDirection
    @objc public enum PresentDirection: Int {
        case left = 1
        case right = 0
        
        /// 构建
        /// - Parameter leftSide: Bool
        internal init(leftSide: Bool) {
            self.init(rawValue: leftSide ? 1 : 0)!
        }
        
        /// UIRectEdge
        internal var edge: UIRectEdge {
            switch self {
            case .left:     return .left
            case .right:    return .right
            }
        }
        
        /// String
        internal var name: String {
            switch self {
            case .left:     return "leftMenuNavigationController"
            case .right:    return "rightMenuNavigationController"
            }
        }
    }
    
    /// Protected<Menu?>
    private var _leftMenu: Protected<Menu?> = Protected(nil) { SideMenuManager.setMenu(fromMenu: $0, toMenu: $1) }
    /// Protected<Menu?>
    private var _rightMenu: Protected<Menu?> = Protected(nil) { SideMenuManager.setMenu(fromMenu: $0, toMenu: $1) }
    
    private var switching: Bool = false
    
    /// Default instance of SideMenuManager.
    public static let `default` = SideMenuManager()
    
    /// Default instance of SideMenuManager (objective-C).
    public class var defaultManager: SideMenuManager {
        return SideMenuManager.default
    }
    
    /// The left menu.
    open var leftMenuNavigationController: SideMenuNavigationController? {
        get {
            if _leftMenu.value?.isHidden == true {
                _leftMenu.value?.leftSide = true
            }
            return _leftMenu.value
        }
        set(menu) { _leftMenu.value = menu }
    }
    
    /// The right menu.
    open var rightMenuNavigationController: SideMenuNavigationController? {
        get {
            if _rightMenu.value?.isHidden == true {
                _rightMenu.value?.leftSide = false
            }
            return _rightMenu.value
        }
        set(menu) { _rightMenu.value = menu }
    }
    
    /**
     Adds screen edge gestures for both left and right sides to a view to present a menu.
     
     - Parameter toView: The view to add gestures to.
     
     - Returns: The array of screen edge gestures added to `toView`.
     */
    @discardableResult public func addScreenEdgePanGesturesToPresent(toView view: UIView) -> [UIScreenEdgePanGestureRecognizer] {
        return [
            addScreenEdgePanGesturesToPresent(toView: view, forMenu: .left),
            addScreenEdgePanGesturesToPresent(toView: view, forMenu: .right)
        ]
    }
    
    /**
     Adds screen edge gestures to a view to present a menu.
     
     - Parameter toView: The view to add gestures to.
     - Parameter forMenu: The menu (left or right) you want to add a gesture for.
     
     - Returns: The screen edge gestures added to `toView`.
     */
    @discardableResult public func addScreenEdgePanGesturesToPresent(toView view: UIView, forMenu side: PresentDirection) -> UIScreenEdgePanGestureRecognizer {
        if menu(forSide: side) == nil {
            let methodName = #function // "addScreenEdgePanGesturesToPresent"
            let suggestedMethodName = "addScreenEdgePanGesturesToPresent(toView:forMenu:))"
            Print.warning(.screenGestureAdded, arguments: methodName, side.name, suggestedMethodName)
        }
        return self.addScreenEdgeGesture(to: view, edge: side.edge)
    }
    
    /**
     Adds a pan edge gesture to a view to present menus.
     
     - Parameter toView: The view to add a pan gesture to.
     
     - Returns: The pan gesture added to `toView`.
     */
    @discardableResult public func addPanGestureToPresent(toView view: UIView) -> UIPanGestureRecognizer {
        if leftMenuNavigationController ?? rightMenuNavigationController == nil {
            Print.warning(.panGestureAdded, arguments: #function, PresentDirection.left.name, PresentDirection.right.name, required: true)
        }
        
        return addPresentPanGesture(to: view)
    }
}

extension SideMenuManager {
    
    /// setMenu
    /// - Parameters:
    ///   - menu: Menu
    ///   - leftSide: Bool
    internal func setMenu(_ menu: Menu?, forLeftSide leftSide: Bool) {
        switch leftSide {
        case true: leftMenuNavigationController = menu
        case false: rightMenuNavigationController = menu
        }
    }
    
    /// setMenu
    /// - Parameters:
    ///   - fromMenu: Menu
    ///   - toMenu: Menu
    /// - Returns: Menu
    private class func setMenu(fromMenu: Menu?, toMenu: Menu?) -> Menu? {
        if fromMenu?.isHidden == false {
            Print.warning(.menuInUse, arguments: PresentDirection.left.name, required: true)
            return fromMenu
        }
        return toMenu
    }
}

extension SideMenuManager {
    
    /// handlePresentMenuScreenEdge
    /// - Parameter gesture: UIScreenEdgePanGestureRecognizer
    @objc private func handlePresentMenuScreenEdge(_ gesture: UIScreenEdgePanGestureRecognizer) {
        handleMenuPan(gesture)
    }
    
    /// handlePresentMenuPan
    /// - Parameter gesture: UIPanGestureRecognizer
    @objc private func handlePresentMenuPan(_ gesture: UIPanGestureRecognizer) {
        handleMenuPan(gesture)
    }
    
    /// handleMenuPan
    /// - Parameter gesture: UIPanGestureRecognizer
    private func handleMenuPan(_ gesture: UIPanGestureRecognizer) {
        if let activeMenu = activeMenu {
            let width = activeMenu.menuWidth
            let distance = gesture.side.xTranslation / width
            switch (gesture.state) {
            case .changed:
                if gesture.side.canSwitch {
                    switching = (distance > 0 && !activeMenu.leftSide) || (distance < 0 && activeMenu.leftSide)
                    if switching {
                        activeMenu.cancelMenuPan(gesture)
                        return
                    }
                }
            default:
                switching = false
            }
            
        } else {
            let leftSide: Bool
            if let gesture = gesture as? UIScreenEdgePanGestureRecognizer {
                leftSide = gesture.edges.contains(.left)
            } else {
                // not sure which way the user is swiping yet, so do nothing
                if gesture.side.xTranslation == 0 { return }
                leftSide = gesture.side.xTranslation > 0
            }
            
            guard let menu = menu(forLeftSide: leftSide) else { return }
            menu.present(from: topMostViewController, interactively: true)
        }
        
        activeMenu?.handleMenuPan(gesture, true)
    }
    
    /// Menu
    private var activeMenu: Menu? {
        if leftMenuNavigationController?.isHidden == false { return leftMenuNavigationController }
        if rightMenuNavigationController?.isHidden == false { return rightMenuNavigationController }
        return nil
    }
    
    /// menu forSide
    /// - Parameter forSide: PresentDirection
    /// - Returns: Menu
    private func menu(forSide: PresentDirection) -> Menu? {
        switch forSide {
        case .left: return leftMenuNavigationController
        case .right: return rightMenuNavigationController
        }
    }
    
    /// menu forLeftSide
    /// - Parameter leftSide: Bool
    /// - Returns: Menu
    private func menu(forLeftSide leftSide: Bool) -> Menu? {
        return menu(forSide: leftSide ? .left : .right)
    }
    
    /// addScreenEdgeGesture
    /// - Parameters:
    ///   - view: UIView
    ///   - edge: UIRectEdge
    /// - Returns: UIScreenEdgePanGestureRecognizer
    private func addScreenEdgeGesture(to view: UIView, edge: UIRectEdge) -> UIScreenEdgePanGestureRecognizer {
        if let screenEdgeGestureRecognizer = view.gestureRecognizers?.first(where: { $0 is SideMenuScreenEdgeGestureRecognizer }) as? SideMenuScreenEdgeGestureRecognizer,
           screenEdgeGestureRecognizer.edges == edge {
            screenEdgeGestureRecognizer.side.remove()
        }
        return SideMenuScreenEdgeGestureRecognizer(addTo: view, target: self, action: #selector(handlePresentMenuScreenEdge(_:))).with {
            $0.edges = edge
        }
    }
    
    /// addPresentPanGesture
    /// - Parameter view: UIView
    /// - Returns: UIPanGestureRecognizer
    @discardableResult
    private func addPresentPanGesture(to view: UIView) -> UIPanGestureRecognizer {
        if let panGestureRecognizer = view.gestureRecognizers?.first(where: { $0 is SideMenuPanGestureRecognizer }) as? SideMenuPanGestureRecognizer {
            return panGestureRecognizer
        }
        return SideMenuPanGestureRecognizer(addTo: view, target: self, action: #selector(handlePresentMenuPan(_:)))
    }
    
    /// UIViewController
    private var topMostViewController: UIViewController? {
        return UIApplication.shared.side.keyWindow?.rootViewController?.side.topMostViewController
    }
}

extension SideMenuManager: SideMenuNavigationControllerTransitionDelegate {
    
    /// sideMenuTransitionDidDismiss
    /// - Parameter menu: Menu
    internal func sideMenuTransitionDidDismiss(menu: Menu) {
        defer { switching = false }
        guard switching, let switchToMenu = self.menu(forLeftSide: !menu.leftSide) else { return }
        switchToMenu.present(from: topMostViewController, interactively: true)
    }
}
