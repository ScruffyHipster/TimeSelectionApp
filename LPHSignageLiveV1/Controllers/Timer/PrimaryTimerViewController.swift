//
//  PrimaryViewController.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 21/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit
import CoreData

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
	@IBOutlet weak var timeLabel: UILabel!
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
	var timeToSet: Int32?
	var theatreName: String?  {
		didSet {
			theatreSelection.text = theatreName
		}
	}
	//references
	var httprequest: Httpv2?
	var group: Httpv2.Group?
	//delegate
	weak var delegate: PrimaryViewControllerDelegate?
	//placeholder to save show times in tableview
	var showTimeArray: Data?
	lazy var noMoreTimerAlert: UIAlertController = {
		let alert = UIAlertController(title: "Failed", message: "The maximum number of timers that can be set have been.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
		return alert
	}()
	
	//placeholder for a focused time
	var theatreTimeFocus: Show?
	//for coreData
	var managedObjectContext: NSManagedObjectContext!
	
	//MARK:- Actions
	@IBAction func resetCountdown(_ sender: UIButton) {
		guard let focusedTime = theatreTimeFocus else {return}
		let focusedTheatreName = focusedTime.theatreName
		if let index = shows.firstIndex(where: {$0.theatreName == focusedTheatreName}) {
			//remove show and timer for specific show in array
			let show = shows[index]
			show.timer?.invalidate()
			show.timer = nil
			shows.remove(at: index)
			timeSelectionView?.shows.remove(at: index)
			managedObjectContext.delete(show)
			do {
				try managedObjectContext.save()
			} catch {
				print(error)
			}
			print("there are \(shows.count) shows left after deleting from CD")
			print("removed timer for theatre \(String(describing: show.theatreName))")
			
			//create an indexpath for the object and then delete it from the tableview
			let indexPaths = IndexPath(item: index, section: 0)
			let indexPath = [indexPaths]
			tableView.deleteRows(at: indexPath, with: .automatic)
			switch show.theatre {
			case 0:
				group = Httpv2.Group.theatreOne
			case 1:
				group = Httpv2.Group.theatreTwo
			case 2:
				group = Httpv2.Group.theatreThree
			default:
				break
			}
			cancelRequest(for: group!)
			if shows.count > 0 {
				//if there is still another show in the array change the information to reflect this
				let show = shows.first
				theatreTimeFocus = show
				startTimeLabelTimer()
				theatreName = theatreTimeFocus?.theatreName
			}//else if nothing left in the show array remove any timer left
		}
		if shows.count == 0 {
			shows = []
			if timer?.isValid ?? false {
				timer?.invalidate()
				print("timer invalidated as there are no more shows running")
			}
			configureTimeLabel(with: 0000, for: timeLabel)
			print("nothing to see here")
			cancelButton.isEnabled = false
			theatreName = TheatreSelectionName.noTheatre.rawValue
		}
		delegate?.numberOfTimersRunning(self, numberOf: shows.count)
	}
	
	func cancelRequest(for group: Httpv2.Group) {
		let url = httprequest?.urlRequestSL(group: group, interrupt: .cancel)
		httprequest?.sendRequest(for: url!, completion: { (success) in
			if success {
				print("removed")
			} else {
				print("failed to remove")
			}
		})
	}
	
	//MARK:- ViewDidLoad
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Select Time"
		httprequest = Httpv2.shared
		setUpCardView()
		
		let fetchRequest = NSFetchRequest<Show>()
		let entity = Show.entity()
		fetchRequest.entity = entity
		let sortDescriptors = NSSortDescriptor(key: "timeToGo", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptors]
		do {
			shows = try managedObjectContext.fetch(fetchRequest)
		} catch {
			print(error)
		}
		tableViewSetup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard let theatre = shows.first else {return}
		theatreTimeFocus = theatre
		theatreSelection.text = theatre.theatreName
		startTimeLabelTimer()
		cancelButton.isEnabled = true
		timeSelectionView?.shows = shows
		delegate?.numberOfTimersRunning(self, numberOf: shows.count)
	}
	
	func tableViewSetup() {
		tableView.delegate = self
		tableView.dataSource = self
	}
	
	
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		timer = nil
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
			vc.managedObjectContext = managedObjectContext
		}
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(recognizer:)))
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(recognizer:)))
		vc.handleView.addGestureRecognizer(panGesture)
		vc.handleView.addGestureRecognizer(tapGesture)
	}
}


extension PrimaryTimerViewController: TimeSelectorViewControllerDelegate {
	//MARK:- TimeSelectorViewControllerDelegate
	
	//called when time has been selected
	
	func didSelectTime(_ controller: TimeSelectorViewController, didAddShow show: Show) {
		//create new index dependant on the number of items in the shows array and add them to the tablerow
		let newIndex = shows.count
		
		shows.append(show)
		
		//adds to the timeselectionview array so it can be checked for duplicate shows and prevent it from being created
		timeSelectionView?.shows.append(show)
		
		//doesnt add another time if the array already has three (i.e number of supported theatres)
		if newIndex < 3 {
			let indexPaths = IndexPath(item: newIndex, section: 0)
			let indexPath = [indexPaths]
			tableView.insertRows(at: indexPath, with: .automatic)
		}
		//only run if the shows array has an object in it. Prevents the time label from being mis-labelled
		if shows.count > 0 {
			//sets the timer running on the instantiated theatre object
			//set focus theatre var
			theatreTimeFocus = show
			//start timer on the specific object
			theatreTimeFocus?.startTimer()
			//set the theatre label to that of the focused theatre
			theatreSelection.text = theatreTimeFocus?.theatreName
			startTimeLabelTimer()
			//Delegate call once timer has fired
			delegate?.numberOfTimersRunning(self, numberOf: shows.count)
		}
		timerIsRunning = true
		cancelButton.isEnabled = true
		tableView.reloadData()
	}
	
	func startTimeLabelTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
			configureTimeLabel(with: (self.theatreTimeFocus?.timeToGo)!, for: self.timeLabel)
		})
	}
	
	//called when request is sent to Signagelive api
	func requestWasSent(_ controller: TimeSelectorViewController, requestSuccess succes: Bool) {
		switch succes {
		case true:
			animateTranistion(fromState: menuState, withDuration: 1)
		case false:
			animateTranistion(fromState: menuState, withDuration: 1)
			let alert = createAlert(title: "Failed", message: "Issue occured", buttonTitle: "Ok")
			present(alert, animated: true)
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
		cell.configureCell(cell, withShow: show)
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
		let show = shows[indexPath.row]
		show.timer?.invalidate()
		shows.remove(at: indexPath.row)
		timeSelectionView?.shows.remove(at: indexPath.row)
		tableView.deleteRows(at: [indexPath], with: .automatic)
		switch show.theatre {
		case 0:
			group = Httpv2.Group.theatreOne
		case 1:
			group = Httpv2.Group.theatreTwo
		case 2:
			group = Httpv2.Group.theatreThree
		default:
			break
		}
		cancelRequest(for: group!)
		managedObjectContext.delete(show)
		do {
			try managedObjectContext.save()
		} catch {
			print("Error occured \(error)")
		}
		if shows.count == 0 {
			cancelButton.isEnabled = false
			theatreSelection.text = TheatreSelectionName.noTheatre.rawValue
		}
		delegate?.numberOfTimersRunning(self, numberOf: shows.count)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		timer = nil
		theatreTimeFocus = shows[indexPath.row]
		theatreName = theatreTimeFocus?.theatreName
		startTimeLabelTimer()
		cancelButton.isEnabled = true
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
			return
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



//****Graveyard for lost code*****//



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


//	func setUpTimer() {
//		//creates a timer
//		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
//			self.timeToSet! -= 1
//			if self.timeToSet! > 0 {
//				configureTimeLabel(with: self.timeToSet!, for: self.timeLabel)
//
//				self.defaults?.set(self.timeToSet, forKey: "countdownTime")
//			}
//			self.timer?.invalidate()
//			self.defaults?.set(nil, forKey: "countdownTime")
//		})
//		cancelButton.isEnabled = true
//	}
