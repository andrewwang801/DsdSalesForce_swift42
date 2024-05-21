//
//  UIViewController+Extension.swift
//  MyTaxPal
//
//  Created by iOS Developer on 5/10/16.
//  Copyright © 2016 Q-Scope. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func setDefaultModalPresentationStyle() {
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    func setFullScreenPresentation() {
        self.modalPresentationStyle = .overFullScreen
    }
    
    static func getViewController(storyboardName: String, storyboardID: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: storyboardID)
        return viewController
    }

    func setAsRoot() {
        let originalVC = UIApplication.shared.keyWindow?.rootViewController
        UIApplication.shared.keyWindow?.rootViewController = self
        originalVC?.dismiss(animated: false, completion: nil)
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}

// MARK: - management of child view controllers in custom container view
extension UIViewController {

    func cycleChild(oldVC: UIViewController, newVC: UIViewController, containerView: UIView, isLeftSlide: Bool, isRemovePrevious: Bool) {

        // Prepare the two view controllers for the change.
        oldVC.willMove(toParent: nil)
        self.addChild(newVC)

        let currentFrame = containerView.bounds
        let offsetWidth = currentFrame.width

        // Get the stat frame of the new controller and the end frame
        // for the old view controller. Both rectangles are offscreen
        var endFrame: CGRect!
        if isLeftSlide == true {
            newVC.view.frame = currentFrame.offsetBy(dx: offsetWidth, dy: 0)
            endFrame = currentFrame.offsetBy(dx: -offsetWidth, dy: 0)
        }
        else {
            newVC.view.frame = currentFrame.offsetBy(dx: -offsetWidth, dy: 0)
            endFrame = currentFrame.offsetBy(dx: offsetWidth, dy: 0)
        }

        // Queue up the transition animation
        self.transition(from: oldVC, to: newVC, duration: 0.25, options: UIView.AnimationOptions(rawValue: 0), animations: {
            // Animate the views to their final positions
            newVC.view.frame = oldVC.view.frame
            oldVC.view.frame = endFrame
        }) { (finished) in
            oldVC.removeFromParent()
            newVC.didMove(toParent: self)

            if isRemovePrevious == true {
                let childVCArray = self.children
                for childVC in childVCArray {
                    if childVC != newVC {
                        childVC.willMove(toParent: nil)
                        childVC.removeFromParent()
                    }
                }
            }
        }
    }

    func cycleChild(newVC: UIViewController, containerView: UIView, isLeftSlide: Bool, isRemovePrevious: Bool) {

        guard let oldVC = self.children.last else {return}
        cycleChild(oldVC: oldVC, newVC: newVC, containerView: containerView, isLeftSlide: isLeftSlide, isRemovePrevious: isRemovePrevious)
    }

    func changeChild(oldVC: UIViewController, newVC: UIViewController, containerView: UIView, isRemovePrevious: Bool) {

        // Prepare the two view controllers for the change.
        oldVC.willMove(toParent: nil)
        self.addChild(newVC)

        let currentFrame = containerView.bounds
        newVC.view.frame = currentFrame

        // Queue up the transition animation
        self.transition(from: oldVC, to: newVC, duration: 0.25, options: UIView.AnimationOptions(rawValue: 0), animations: {
        }) { (finished) in
            oldVC.removeFromParent()
            newVC.didMove(toParent: self)

            if isRemovePrevious == true {
                let childVCArray = self.children
                for childVC in childVCArray {
                    if childVC != newVC {
                        childVC.willMove(toParent: nil)
                        childVC.removeFromParent()
                    }
                }
            }
        }
    }

    func changeChild(newVC: UIViewController, containerView: UIView, isRemovePrevious: Bool) {

        guard let oldVC = self.children.last else {return}
        changeChild(oldVC: oldVC, newVC: newVC, containerView: containerView, isRemovePrevious: isRemovePrevious)
    }

    func pushChild(newVC: UIViewController, containerView: UIView) {

        guard let oldVC = self.children.last else {return}
        oldVC.willMove(toParent: nil)
        self.addChild(newVC)

        let currentFrame = containerView.bounds
        let offsetWidth = currentFrame.width

        // Get the stat frame of the new controller and the end frame
        // for the old view controller. Both rectangles are offscreen
        newVC.view.frame = currentFrame.offsetBy(dx: offsetWidth, dy: 0)
        let endFrame = currentFrame.offsetBy(dx: -offsetWidth, dy: 0)

        // Queue up the transition animation
        self.transition(from: oldVC, to: newVC, duration: 0.5, options: UIView.AnimationOptions(rawValue: 0), animations: {
            // Animate the views to their final positions
            newVC.view.frame = oldVC.view.frame
            oldVC.view.frame = endFrame
        }) { (finished) in
            newVC.didMove(toParent: self)
        }
    }

    func popChild(containerView: UIView) {
        popChild(containerView: containerView, completionHandler: nil)
    }

    func popChild(containerView: UIView, completionHandler:((Bool)->())?) {
        guard let oldVC = self.children.last else {return}
        let childCount = self.children.count
        if childCount < 2 {
            return
        }

        let newVC = self.children[childCount-2]

        oldVC.willMove(toParent: nil)

        let currentFrame = containerView.bounds
        let offsetWidth = currentFrame.width

        // Get the stat frame of the new controller and the end frame
        // for the old view controller. Both rectangles are offscreen
        newVC.view.frame = currentFrame.offsetBy(dx: -offsetWidth, dy: 0)
        let endFrame = currentFrame.offsetBy(dx: offsetWidth, dy: 0)

        // Queue up the transition animation
        self.transition(from: oldVC, to: newVC, duration: 0.25, options: UIView.AnimationOptions(rawValue: 0), animations: {
            // Animate the views to their final positions
            newVC.view.frame = oldVC.view.frame
            oldVC.view.frame = endFrame
        }) { (finished) in
            oldVC.removeFromParent()
            newVC.didMove(toParent: self)
            completionHandler?(finished)
        }
    }
}

