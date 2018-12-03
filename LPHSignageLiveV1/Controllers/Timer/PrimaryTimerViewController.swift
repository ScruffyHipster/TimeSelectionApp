//
//  PrimaryViewController.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 21/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

protocol PrimaryViewControllerDelegate: class {
	func numberOfTimersRunning(_ controller: PrimaryTimerViewController, numberOf shows: Int)
}

protocol PrimaryViewControllerTimerDelegate: class {
	func updateTimer(_ time: Int)
}





class PrimaryTimerViewController: UIViewController {
	
	//MARK:- Outlets
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.text = ""
		}
	}
	@IBOutlet weak var timeLabel: UILabel! {
		didSet {
			timeLabel.text = "00:00"
		}
	}
	@IBOutlet weak var cancelButton: UIButton! {
		didSet {
			if shows.count == 0 {
				cancelButton.isEnabled = false
			}
		}
	}
	@IBOutlet weak var fadeView: UIView!
	@IBOutlet weak var timeStack: UIStackView!
	@IBOutlet weak var theatreSelection: UILabel!
	@IBOutlet weak var tableView: UITableView!
	
	//MARK:- Properties
	
	var shows = [Show]()
	
	//For the slider animation
	var menusVisible = false
	var menuState: TimeSelectionViewState {
		return menusVisible ? .compressed : .fullHeight
	}
	var menuHeight: CGFloat = 720
	var compressedHeight: CGFloat = 70
	var timeSelectionView: TimeSelectorViewController?
	var runningAnimations = [UIViewPropertyAnimator]()
	var animationProgressWhenInteruppted: CGFloat = 0
	
	// Timer and Theatre properties
	var timer: Timer?
	lazy var currentTime: Date = {
		var date = Date()
		return date
	}()
	var timers: [Double]?
	var timerIsRunning = false
	var timeToSet: Int?
	var theatreName: TheatreSelectionName?  {
		didSet {
			theatreSelection.text = theatreName?.rawValue
		}
	}
	//references
	var httprequest: HTTPRequest?
	var defaults: UserDefaults?
	//delegate
	weak var delegate: PrimaryViewControllerDelegate?
	//placeholder to save show times in tableview
	var showTimeArray: Data?
	lazy var noMoreTimerAlert: UIAlertController = {
		let alert = UIAlertController(title: "Failed", message: "The maximum number of timers that can be set have been.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
		return alert
	}()
	
	//MARK:- Actions
	@IBAction func resetCountdown(_ sender: UIButton) {
		if timerIsRunning {
			timer?.invalidate()
			timerIsRunning = false
			timeLabel.text = "00:00"
			if shows.count == 0 {
				cancelButton.isEnabled = false
			}
			delegate?.numberOfTimersRunning(self, numberOf: shows.count)
			//MARK:- TODO add request to cancel time off the SL server
			//remove from the table view
			//gets the string
			//compares the string against the theatre name selected
			if let theatreName = theatreName?.rawValue {
				if let index = shows.firstIndex(where: {$0.theatreName.rawValue == theatreName}) {
					shows.remove(at: index)
				}
				print("removed at index of \(theatreName)")
			}
			tableView.reloadData()
			delegate?.numberOfTimersRunning(self, numberOf: shows.count)
			theatreName = TheatreSelectionName.noTheatre
		}
	}
	
	//MARK:- ViewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Select Time"
		theatreName = TheatreSelectionName.noTheatre
		httprequest = HTTPRequest.shared
		setUpCardView()
		tableViewSetup()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadData()
		delegate?.numberOfTimersRunning(self, numberOf: shows.count)
	}
	
	func tableViewSetup() {
		tableView.delegate = self
		tableView.dataSource = self
	}
	
	func setUpTimer() {
		//creates a timer
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
			self.timeToSet! -= 1
			if self.timeToSet! > 0 {
				configureTimeLabel(with: self.timeToSet!, for: self.timeLabel)
				
				self.defaults?.set(self.timeToSet, forKey: "countdownTime")
			}
			self.timer?.invalidate()
			self.defaults?.set(nil, forKey: "countdownTime")
		})
		cancelButton.isEnabled = true
	}
	

	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		saveData()
		timer?.invalidate()
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
		
		//Inject below vars if subview has loaded
		if self.children[0] == vc {
			vc.delegate = self
			vc.defaults = defaults
		}
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(recognizer:)))
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(recognizer:)))
		vc.handleView.addGestureRecognizer(panGesture)
		vc.handleView.addGestureRecognizer(tapGesture)
	}
	
	func loadData() {
		//load any saved timers
		let theatre = defaults?.object(forKey: "theatreName") as? String ?? "Select Theatre"
		let savedCountdownTime = defaults?.object(forKey: "countdownTime") as? Int ?? 0
		let isTimerRunning = defaults?.object(forKey: "timerIsRunning") as? Bool ?? false
		guard let oldTime = defaults?.object(forKey: "oldTime") as? Date else {return}
		let timeDifference = Date().timeIntervalSince(oldTime)
		
		//set to the correct properties
		theatreName = TheatreSelectionName(rawValue: theatre)
		timeToSet = savedCountdownTime
		timerIsRunning = isTimerRunning
		
		if isTimerRunning {
			if timeDifference.isLess(than: Double(savedCountdownTime)) {
				timeToSet = Int(Double(savedCountdownTime) - timeDifference)
				//set up timer view if timer is already running
				setUpTimer()
			}
		}
		
		showTimeArray = defaults?.data(forKey: "showTimeArray")
		if showTimeArray != nil {
			do {
				shows = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(showTimeArray!) as! [Show]
				print("show time array is not empty. It has \(shows.count)")
			} catch {
				print(error)
			}
		}
		tableView.reloadData()
	}
	
	func saveData() {
		//Save info when exiting
		defaults?.set(currentTime, forKey: "oldTime")
		defaults?.set(timerIsRunning, forKey: "timerIsRunning")
		defaults?.set(theatreName?.rawValue, forKey: "theatreName")
		do {
			showTimeArray = try NSKeyedArchiver.archivedData(withRootObject: shows, requiringSecureCoding: false)
		} catch {
			print(error)
		}
		defaults?.set(showTimeArray, forKey: "showTimeArray")
	}
}


extension PrimaryTimerViewController: TimeSelectorViewControllerDelegate {
	//MARK:- TimeSelectorViewControllerDelegate
	
	//called when time has been selected
	
	func didSelectTime(_ controller: TimeSelectorViewController, didAddShow show: Show) {
		theatreName = TheatreSelectionName(rawValue: show.theatreName.rawValue)
		if timerIsRunning {
			timer?.invalidate()
		}
		//create new index dependant on the number of items in the shows array and add them to the tablerow
		let newIndex = shows.count
		shows.append(show)
		//Delegate
		delegate?.numberOfTimersRunning(self, numberOf: shows.count)
		//create timer to show on this view
		timeToSet = 0
		timeToSet = show.timeToGo
		show.startTimer()
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
			if show.timeToGo > 0 {
				configureTimeLabel(with: show.timeToGo, for: self.timeLabel)
				self.defaults?.set(self.timeToSet, forKey: "countdownTime")
			} else {
				self.timer?.invalidate()
				self.defaults?.set(nil, forKey: "countdownTime")
			}
		})
		
		timerIsRunning = true
		cancelButton.isEnabled = true
		
		//doesnt add another time if the array already has three (i.e number of supported theatres)
		if newIndex < 3 {
			let indexPaths = IndexPath(item: newIndex, section: 0)
			let indexPath = [indexPaths]
			tableView.insertRows(at: indexPath, with: .automatic)
		}
		tableView.reloadData()
	}
	
	//called when request is sent to Signagelive api
	func requestWasSent(_ controller: TimeSelectorViewController, requestSuccess succes: Bool) {
		switch succes {
		case true:
			animateTranistion(fromState: menuState, withDuration: 1)
		case false:
			break
			//MARK:- TODO add if returns false function
		}
	}
	
}



extension PrimaryTimerViewController: UITableViewDelegate, UITableViewDataSource {
	//MARK:- Tableview datasource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return shows.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell") as! TimeSelectorTableViewCell
		let show = shows[indexPath.row]
		Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
			cell.configureCell(cell, withShow: show)
		}
		//self.timerDelegate = cell
		return cell
	}
	
	//MARK:- tableview delegate
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.frame.height / 3
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.frame.height / 3
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		//TODO: add way of removing the timers
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		theatreName = shows[indexPath.row].theatreName
		configureTimeLabel(with: shows[indexPath.row].timeToGo, for: timeLabel)
	}
}


extension PrimaryTimerViewController {
	//MARK:- Gesture recognizers
	@objc func panGestureRecognizer(recognizer: UIPanGestureRecognizer) {
		if shows.count < 3 {
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
		} else {
			present(noMoreTimerAlert, animated: true)
		}
	}
	
	@objc func tapGestureRecognizer(recognizer: UITapGestureRecognizer) {
		if shows.count < 3 {
			if recognizer.state == .ended {
				animateTranistion(fromState: menuState, withDuration: 0.7)
			} else {
				present(noMoreTimerAlert, animated: true)
			}
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







//	//Countdown call function
//	@objc func updateCountdown() {
//		timeToSet! -= 1
//		if timeToSet! > 0 {
//			configureTimeLabel(with: timeToSet!, for: timeLabel)
//			//Saves the values for references
//			defaults?.set(timeToSet, forKey: "countdownTime")
//		} else {
//			//sets the saved time to nil
//			defaults?.set(nil, forKey: "countdownTime")
//			timer?.invalidate()
//		}
//	}
