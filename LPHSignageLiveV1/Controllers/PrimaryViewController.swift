//
//  PrimaryViewController.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 21/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class PrimaryViewController: UIViewController {
	
	//MARK:- Outlets
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var cancelButton: UIButton!
	
	//MARL:- Properties
	var menusVisible = false
	var menuState: TimeSelectionViewState {
		return menusVisible ? .compressed : .fullHeight
	}
	var menuHeight: CGFloat = 620
	var compressedHeight: CGFloat = 70
	var timeSelectionView: TimeSelectorViewController?
	var runningAnimations = [UIViewPropertyAnimator]()
	var animationProgressWhenInteruppted: CGFloat = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Select Time"
		setUpCardView()
	}
	
	func setUpCardView() {
		let storyBoard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyBoard.instantiateViewController(withIdentifier: "timeSelectorViewController") as! TimeSelectorViewController
		timeSelectionView = vc
		self.addChild(vc)
		vc.didMove(toParent: self)
		self.view.addSubview(vc.view)
		vc.view.frame = CGRect(x: 0, y: self.view.frame.height - compressedHeight, width: self.view.frame.width, height: self.view.frame.height)
		vc.handleView.layer.cornerRadius = 8.0
		vc.view.layer.cornerRadius = 8.0
		vc.handleView.clipsToBounds = true
		vc.handleView.layer.shadowOpacity = 0.8
		
		if self.children[0] == vc {
			vc.delegate = self
		}
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(recognizer:)))
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(recognizer:)))
		vc.handleView.addGestureRecognizer(panGesture)
		vc.handleView.addGestureRecognizer(tapGesture)
	}
	
}



extension PrimaryViewController {
	//MARK:- Gesture recognizers
	@objc func panGestureRecognizer(recognizer: UIPanGestureRecognizer) {
		switch recognizer.state {
		case .ended:
			continueInteractiveTransition()
			break
		case .changed:
			let translation = recognizer.translation(in: timeSelectionView?.handleView)
			var fractionComplete = translation.y / menuHeight
			fractionComplete = menusVisible ? fractionComplete : -fractionComplete
			updateInteractiveTransition(fractionCompleted: fractionComplete)
			break
		case .began:
			startInteractiveTransition(state: menuState, duration: 0.7)
			break
		default:
			break
		}
	}
	
	@objc func tapGestureRecognizer(recognizer: UITapGestureRecognizer) {
		if recognizer.state == .ended {
			animateTranistion(fromState: menuState, withDuration: 0.7)
		}
	}
	
	func startInteractiveTransition(state: TimeSelectionViewState, duration: Double) {
		if runningAnimations.isEmpty {
			animateTranistion(fromState: state, withDuration: duration)
		}
		for animator in runningAnimations {
			animator.pauseAnimation()
			animationProgressWhenInteruppted = animator.fractionComplete
		}
	}
	
	func animateTranistion(fromState state: TimeSelectionViewState, withDuration duration: Double) {
		guard let timeSelectionView = timeSelectionView else {return}
		if runningAnimations.isEmpty {
			let frameAnimator = UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.7) {
				switch state {
				case .compressed:
					timeSelectionView.view.frame.origin.y = self.view.frame.height - self.compressedHeight
				case .fullHeight:
					timeSelectionView.view.frame.origin.y = self.view.frame.height - self.menuHeight
				}
			}
			frameAnimator.addCompletion { _ in
				self.menusVisible = !self.menusVisible
				self.runningAnimations.removeAll()
			}
			frameAnimator.startAnimation()
			runningAnimations.append(frameAnimator)
		}
	}
	
	func updateInteractiveTransition(fractionCompleted: CGFloat) {
		for animator in runningAnimations {
			animator.fractionComplete = fractionCompleted + animationProgressWhenInteruppted
		}
	}
	
	func continueInteractiveTransition() {
		for animator in runningAnimations {
			animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
		}
	}
}

extension PrimaryViewController: TimeSelectorViewControllerDelegate {
	
	func didSelectTime(_ controller: TimeSelectorViewController, timeSelected time: Double) {
		let timer = Timer(timeInterval: <#T##TimeInterval#>, target: <#T##Any#>, selector: <#T##Selector#>, userInfo: <#T##Any?#>, repeats: <#T##Bool#>)
		timeLabel.text = String("\(time)")
	}
	
	
}


