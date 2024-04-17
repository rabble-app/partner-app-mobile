//
//  PushAnimator.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 4/17/24.
//

import Foundation
import UIKit

class PushAnimator: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension PushAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3 // Set your desired animation duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let fromView = fromVC.view,
              let toView = toVC.view else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        
        if toVC.isBeingPresented { // Presenting animation
            // Set the initial position of the toView
            toView.frame = CGRect(x: containerView.frame.width, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            containerView.addSubview(toView)
            
            // Perform the animation
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                toView.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else if fromVC.isBeingDismissed { // Dismissing animation
            // Perform the animation
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromView.frame = CGRect(x: containerView.frame.width, y: 0, width: containerView.frame.width, height: containerView.frame.height)
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}

