//
//  PrimaryViewController.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 21/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

protocol PrimaryViewControllerDelegate: class {
	//Send the time data back to the previous vc if set
	func didSetCountdownRunning(_ controller: PrimaryTimerViewController, timerSet: Bool, timeRunning time: Double)
}

class PrimaryTimerViewController: UIViewController {
	
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
	@IBOutlet weak var theatreSelection: UILabel!
	
	//MARK:- Properties
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
	lazy var currentTime: Date = {
		var date = Date()
		return date
	}()
	var timers: [Double]?
	var timerIsRunning = false
	var timeToSet: Int?
	var httprequest: HTTPRequest?
	var defaults: UserDefaults?
	var theatreName: String?  {
		didSet {
			theatreSelection.text = theatreName
		}
	}
	weak var delegate: PrimaryViewControllerDelegate?
	
	//MARK:- Actions
	@IBAction func resetCountdown(_ sender: UIButton) {
		if timerIsRunning {
			print("Cancelled")
			timer?.invalidate()
			timerIsRunning = false
			minutesLabel.text = String("00")
			secondsLabel.text = String("00")
			cancelButton.isEnabled = false
			theatreName = "Theatre"
			//MARK:- TODO //need to change the below request to be updated with the group from the selected theatre/ interupt
		}
	}
	
	//MARK:- ViewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Select Time"
		httprequest = HTTPRequest.shared
		setUpCardView()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let theatre = defaults?.object(forKey: "theatreName") as? String ?? "Theatre"
		let savedCountdownTime = defaults?.object(forKey: "countdownTime") as? Int ?? 0
		let isTimerRunning = defaults?.object(forKey: "timerIsRunning") as? Bool ?? false
		guard let oldTime = defaults?.object(forKey: "oldTime") as? Date else {return}
		let timeDifference = Date().timeIntervalSince(oldTime)
		
		theatreName = theatre
		timeToSet = savedCountdownTime
		timerIsRunning = isTimerRunning
		
		if isTimerRunning {
			if timeDifference.isLess(than: Double(savedCountdownTime)) {
				timeToSet = Int(Double(savedCountdownTime) - timeDifference)
				print("Time is less than the saved countdown time \(savedCountdownTime)")
				setUpTimer()
			}
		}
	}
	
	func setUpTimer() {
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
		cancelButton.isEnabled = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		//Save info when exiting
		defaults?.set(currentTime, forKey: "oldTime")
		defaults?.set(timerIsRunning, forKey: "timerIsRunning")
		defaults?.set(theatreName, forKey: "theatreName")
		timer?.invalidate()
	}
	
	deinit {
		print("deallocated")
	}
	
	//MARK:- Functions
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
			vc.defaults = defaults
		}
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(recognizer:)))
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(recognizer:)))
		vc.handleView.addGestureRecognizer(panGesture)
		vc.handleView.addGestureRecognizer(tapGesture)
	}
	
}



extension PrimaryTimerViewController {
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

extension PrimaryTimerViewController: TimeSelectorViewControllerDelegate {
	
	//MARK:- TimeSelectorViewControllerDelegate
	
	func requestWasSent(_ controller: TimeSelectorViewController, requestSuccess succes: Bool) {
		switch succes {
		case true:
			animateTranistion(fromState: menuState, withDuration: 1)
		case false:
			break
			//MARK:- TODO add if returns false function
		}
	}
	
	
	func didSelectTime(_ controller: TimeSelectorViewController, timeSelected time: Double, theatreSelected theatreSelection: Int) {
		switch theatreSelection {
		case 0:
			theatreName = "Quarry"
			break
		case 1:
			theatreName = "Theatre 2"
			break
		case 2:
			theatreName = "Theatre 3"
			break
		default:
			break
		}
		if timerIsRunning {
			timer?.invalidate()
		}
		timeToSet = 0
		timeToSet = Int(time)
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
		//Saves the timer countdown
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
			//Saves the values for references
			defaults?.set(timeToSet, forKey: "countdownTime")
			print("there are \(minutes) minutes set")
			print("there are \(seconds) seconds set")
		} else {
			//sets the saved time to nil
			defaults?.set(nil, forKey: "time")
			timer?.invalidate()
		}
	}
	
	
}


