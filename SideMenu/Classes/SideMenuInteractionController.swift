//
//  SideMenuInteractiveTransitionController.swift
//  SideMenu
//
//  Created by Jon Kent on 12/28/18.
//

import UIKit

final class SideMenuInteractionController: UIPercentDrivenInteractiveTransition {
    
    /// State
    internal enum State {
        case update(progress: CGFloat)
        case finish
        case cancel
    }
    
    /// Bool
    internal private(set) var isCancelled: Bool = false
    /// Bool
    internal private(set) var isFinished: Bool = false
    
    /// 构建
    /// - Parameters:
    ///   - cancelWhenBackgrounded: Bool
    ///   - completionCurve: UIView.AnimationCurve
    internal init(cancelWhenBackgrounded: Bool = true, completionCurve: UIView.AnimationCurve = .easeIn) {
        super.init()
        self.completionCurve = completionCurve
        guard cancelWhenBackgrounded else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    /// cancel
    internal override func cancel() {
        isCancelled = true
        super.cancel()
    }
    
    /// finish
    internal override func finish() {
        isFinished = true
        super.finish()
    }
    
    /// update
    /// - Parameter percentComplete: CGFloat
    internal override func update(_ percentComplete: CGFloat) {
        guard !isCancelled && !isFinished else { return }
        super.update(percentComplete)
    }
    
    /// handle
    /// - Parameter state: State
    internal func handle(state: State) {
        switch state {
        case .update(let progress):
            update(progress)
        case .finish:
            finish()
        case .cancel:
            cancel()
        }
    }
}

extension SideMenuInteractionController {
    
    /// handleNotification
    /// - Parameter notification: NSNotification
    @objc private func handleNotification(notification: NSNotification) {
        switch notification.name {
        case UIApplication.didEnterBackgroundNotification:
            cancel()
        default: break
        }
    }
}
