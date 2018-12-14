////
////  TransitionDelegate.swift
////  LPHSignageLiveV1
////
////  Created by Tom Murray on 13/12/2018.
////  Copyright © 2018 Tom Murray. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//
//class CellAnimator: NSObject, UIViewControllerAnimatedTransitioning {
//
//	let duration = 1.0
//	var originFrame = CGRect.zero
//	var presenting = true
//	var dismissCompletion: (() -> Void)?
//
//
//	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//		return duration
//	}
//
//	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//		let containerView = transitionContext.containerView
//		let toView = transitionContext.view(forKey: .to)!
//		let timeView = presenting ? toView : transitionContext.view(forKey: .from)!
//
//		let initialFrame = presenting ? originFrame : timeView.frame
//		let finalFrame = presenting ? timeView.frame : originFrame
//
//
//		let xScaleFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
//		let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height
//
//		let scaleFactor = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
//
//		if presenting {
//			timeView.transform = scaleFactor
//			timeView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
//			timeView.clipsToBounds = true
//		}
//
//		timeView.layer.cornerRadius = presenting ? 20.0 / xScaleFactor : 0.0
//		timeView.clipsToBounds = true
//
//		containerView.addSubview(toView)
//		containerView.bringSubviewToFront(timeView)
//
//		if presenting {
//			UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, animations: {
//				timeView.transform = .identity
//				timeView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
//			}) { (_) in
//				transitionContext.completeTransition(true)
//			}
//		} else {
//			UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, animations: {
//				timeView.transform = scaleFactor
//				timeView.center = CGPoint(x: self.originFrame.midX, y: self.originFrame.midY)
//			}) { (_) in
//				if !self.presenting {
//					self.dismissCompletion?()
//
//				}
//				transitionContext.completeTransition(false)
//			}
//		}
//	}
//
//}
