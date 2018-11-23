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
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.text = ""
		}
	}
	@IBOutlet weak var minutesLabel: UILabel! {
		didSet {
			minutesLabel.text = "00"
		}
	}
	@IBOutlet weak var secondsLabel: UILabel! {
		didSet {
			secondsLabel.text = "00"
		}
	}
	@IBOutlet weak var cancelButton: UIButton! {
		didSet {
			if !timerIsRunning {
				cancelButton.isEnabled = false
			}
		}
	}
	@IBOutlet weak var fadeView: UIView!
	@IBOutlet weak var timeStack: UIStackView!
	
	//MARL:- Properties
	var menusVisible = false
	var menuState: TimeSelectionViewState {
		return menusVisible ? .compressed : .fullHeight
	}
	var menuHeight: CGFloat = 650
	var compressedHeight: CGFloat = 70
	var timeSelectionView: TimeSelectorViewController?
	var runningAnimations = [UIViewPropertyAnimator]()
	var animationProgressWhenInteruppted: CGFloat = 0
	var timer: Timer?
	var timerIsRunning = false
	var timeToSet: Int?
	
	
	@IBAction func resetCountdown(_ sender: UIButton) {
		if timerIsRunning {
			timer?.invalidate()
			UIView.transition(with: timeStack, duration: 0.7, options: .transitionFlipFromBottom, animations: {
				self.minutesLabel.text = "00"
				self.secondsLabel.text = "00"
				self.view.layoutIfNeeded()
			}, completion: {_ in
				self.timerIsRunning = false
				self.cancelButton.isEnabled = false
			})
			//MARK:- TODO //need to change the below request to be updated with the group from the selected theatre/ interupt
//			HTTPRequest.shared.setTime(for: HTTPRequest.Group(rawValue: 0)!, with: HTTPRequest.Interrupt(rawValue: 4717)!) { (_) in
//				//DO something to show request was successful or not
//			}
		}
	}
	
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
		vc.view.layer.shadowOpacity = 0.2
		vc.handleView.layer.shadowOffset = CGSize(width: vc.handleView.frame.width, height: -2.00)
		
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
		
		let fadeBackground = UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.7) {
			switch state {
			case .compressed:
				self.fadeView.alpha = 0
				break
			case .fullHeight:
				self.fadeView.alpha = 1
				break
			}
		}
		fadeBackground.startAnimation()
		runningAnimations.append(fadeBackground)
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
	//MARK:- TimeSelectorViewControllerDelegate
	
	func requestWasSent(_ controller: TimeSelectorViewController, requestSuccess succes: Bool) {
		switch succes {
		case true:
			animateTranistion(fromState: menuState, withDuration: 0.8)
		case false:
			break
		//MARK:- TODO add if returns false function
		default:
			break
		}
	}
	
	
	func didSelectTime(_ controller: TimeSelectorViewController, timeSelected time: Double) {
		timeToSet = 0
		timeToSet = Int(time)
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
		timerIsRunning = true
		cancelButton.isEnabled = true
	}
	
	@objc func updateCountdown() {
		timeToSet! -= 1
		if timeToSet! > 0 {
			let minutes = timeToSet! / 60 % 60
			let seconds = timeToSet! % 60
			minutesLabel.text = String(format: "%02i", minutes)
			secondsLabel.text = String(format: "%02i", seconds)
			print("there are \(minutes) minutes set")
			print("there are \(seconds) seconds set")
		} else {
			timer?.invalidate()
		}
	}
	
	
}


