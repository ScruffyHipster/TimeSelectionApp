//
//  TimeSelectorViewController.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 31/10/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit
import MSCircularSlider
import Reachability
import CoreData

protocol TimeSelectorViewControllerDelegate: class {
	
	//MARK:- functions to set the time and theatre selected
	func didSelectTime(_ controller: TimeSelectorViewController, didAddShow show: Show)
	
	//MARK:- use function to dismiss the child view controller on successful sent request
	func requestWasSent(_ controller: TimeSelectorViewController, requestSuccess succes: Bool)
}

class TimeSelectorViewController: UIViewController {
	
	//MARK:- Outlets
	
	@IBOutlet var sliderView: MSCircularSlider! 
	@IBOutlet weak var theatreSelection: UISegmentedControl!
	@IBOutlet weak var resetButton: UIButton!
	@IBOutlet weak var handleView: UIView!
	@IBOutlet weak var selectTimeButton: UIButton!
	@IBOutlet weak var blurView: UIView! {
		didSet {
			blurView.alpha = 0
		}
	}
	@IBOutlet weak var timeLabel: UILabel! {
		didSet {
			timeLabel.text = String("\(Int(0))")
		}
	}
	
	//MARK:- Actions
	@IBAction func resetTimer(_ sender: Any) {
		reset()
	}
	@IBAction func selectLabelTapped(_ sender: UIButton) {
		sendTime1()
	}
	
	
	//MARK:- Properties
	var timeToSend: Double {
		get {
			return Double(sliderView!.currentValue)
		}
	}
	
	var theatre: Int? {
		get {
			return theatreSelection.selectedSegmentIndex
		}
	}
	
	var theatreName: String?
	var httpRequest: HTTPRequest?
	var httpRequest2: Httpv2?
//	var interrupt: HTTPRequest.Interrupt?
	var timeToShow2: Int?
	var reachability = Reachability()
	weak var delegate: TimeSelectorViewControllerDelegate?
	var managedObjectContext: NSManagedObjectContext!
	var shows = [Show]()
	
	var interupt: Httpv2.Interrupt?
	var group: Httpv2.Group?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		selectTimeButton.isEnabled = false
		sliderView.delegate = self
		httpRequest = HTTPRequest.shared
		httpRequest2 = Httpv2.shared
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	func reset() {
		if sliderView.currentValue != 0 {
			sliderView.currentValue = 0
			theatreSelection.selectedSegmentIndex = 0
		}
	}
	
	
	func countDownTime(_ time: Double) -> Double {
		switch time {
		case 10:
			return 600
		case 20:
			return 1200
		case 30:
			return 1800
		default:
			return 2400
		}
	}
	
	
}

extension TimeSelectorViewController {
	
	//MARK:- http methods
	
	func sendTime1() {
		
		UIView.animate(withDuration: 0.2) {
			self.blurView.alpha = 1
			self.view.layoutIfNeeded()
		}
		
		let hudView = HUDView.hud(inView: (navigationController?.view)!, animated: true)
		hudView.text = "Sending request"
		
		//TODO: carry on changing this network request
		
		switch timeToSend {
		case 10:
			interupt = Httpv2.Interrupt.ten
			timeToShow2 = 600
		case 20:
			interupt = Httpv2.Interrupt.twenty
			timeToShow2 = 1200
		case 30:
			interupt = Httpv2.Interrupt.thirty
			timeToShow2 = 1800
		default:
			break
		}
		
		
		//sorts out the theatre to interact with
		switch theatre {
		case 0:
			group = Httpv2.Group.theatreOne
			theatreName = TheatreSelectionName.quarryTheatre.rawValue
		case 1:
			group = Httpv2.Group.theatreTwo
			theatreName = TheatreSelectionName.theatre2.rawValue
		case 2:
			group = Httpv2.Group.theatreThree
			theatreName = TheatreSelectionName.theatre3.rawValue
		default:
			break
		}
		
		
		guard let interupt = interupt else {return}
		guard let group = group else {return}
		theatreName = theatreName ?? "No theatre selected"
		
		//checks if the show has already been added to the shows array. if it has, dont send the request.
		for show in shows {
			if show.theatreName == theatreName {
				UIView.animate(withDuration: 1, animations: {
					self.blurView.alpha = 0
					self.reset()
					hudView.hide()
					self.delegate?.requestWasSent(self, requestSuccess: false)
				})
				return
			}
		}
		
		let url = httpRequest2?.urlRequestSL(group: group, interrupt: interupt)
		httpRequest2?.sendRequest(for: url!, completion: { (success) in
			if success {
				let show = Show(context: self.managedObjectContext)
				show.timeToGo = Int32(self.countDownTime(self.timeToSend))
				show.theatreName = self.theatreName
				show.theatre = Int32(self.theatre!)
				do {
					try self.managedObjectContext.save()
				} catch {
					NotificationCenter.default.post(name: coreDataSaveFailedNotification, object: nil)
					print("An error has occured when trying to save \(error.localizedDescription)")
				}
				UIView.animate(withDuration: 0.2, animations: {
					hudView.hide()
					self.blurView.alpha = 0
					self.view.layoutIfNeeded()
				}, completion: { _ in
					self.reset()
					self.delegate?.requestWasSent(self, requestSuccess: true)
				})
				self.delegate?.didSelectTime(self, didAddShow: show)
				self.interupt = nil
				self.theatreName = nil
				print("success")
			} else {
				UIView.animate(withDuration: 0.2, animations: {
					hudView.hide()
					self.blurView.alpha = 0
					self.view.layoutIfNeeded()
				})
				print("failed")
			}
		})
	}
	

}

extension TimeSelectorViewController: MSCircularSliderDelegate {
	
	//MARK:- Delegate functions
	func circularSlider(_ slider: MSCircularSlider, valueChangedTo value: Double, fromUser: Bool) {
		
		//TODO:- sort this out below!
		if sliderView.currentValue == 10.0 {
			self.timeLabel.text = String("\(Int(value))")
		} else if sliderView.currentValue == 20.0 {
			self.timeLabel.text = String("\(Int(value))")
		} else if sliderView.currentValue == 30.0 {
			self.timeLabel.text = String("\(Int(value))")
		} else if sliderView.currentValue == 0.00 {
			self.timeLabel.text = String(0)
		}
		
		if value == 0 {
			selectTimeButton.isEnabled = false
		} else if value > 0
		{
			selectTimeButton.isEnabled = true
		}
	}
	
	func circularSlider(_ slider: MSCircularSlider, startedTrackingWith value: Double) {
		//Optional
	}
	
	func circularSlider(_ slider: MSCircularSlider, endedTrackingWith value: Double) {
		//Optional
	}
}





//	func sendTime() {
//		//check is the theatre is already in the show array
//
//		UIView.animate(withDuration: 0.2) {
//			self.blurView.alpha = 1
//			self.view.layoutIfNeeded()
//		}
//		//hudView with spinning animator
//		let hudView = HUDView.hud(inView: (navigationController?.view)!, animated: true)
//		hudView.text = "Sending request"
//		//unwraps options theatre screens first
//		guard let theatre = theatre else {return}
//		//gets the time to send from the slider view
//		guard let interrupt = HTTPRequest.Interrupt(rawValue: timeToSend) else {return}
//		//gets the group from the segmented selection using the unwrapped var above
//		guard let group = HTTPRequest.Group(rawValue: theatre) else {return}
//		//set the theatre name dependant on selected theatre from the segemented index
//		switch theatre {
//		case 0:
//			theatreName = TheatreSelectionName.quarryTheatre.rawValue
//		case 1:
//			theatreName = TheatreSelectionName.theatre2.rawValue
//		case 2:
//			theatreName = TheatreSelectionName.theatre3.rawValue
//		default:
//			break
//		}
//		guard let theatreName = theatreName else {return}
//
//		for show in shows {
//			if show.theatreName == theatreName {
//				UIView.animate(withDuration: 1) {
//					hudView.hide()
//					self.blurView.alpha = 0
//					self.reset()
//					self.delegate?.requestWasSent(self, requestSuccess: false)
//				}
//				return
//			}
//		}
//
//		httpRequest?.setTime(for: group, with: interrupt, completion: { (success) in
//			if success == true {
//				print("yay")
//				//create a managed object to then save to coreData
//				let show = Show(context: self.managedObjectContext)
//				show.timeToGo = Int32(self.countDownTime(self.timeToSend))
//				show.theatreName = theatreName
//				show.theatre = Int32(theatre)
//				do {
//					try self.managedObjectContext.save()
//				} catch {
//					NotificationCenter.default.post(name: coreDataSaveFailedNotification, object: nil)
//				}
//				UIView.animate(withDuration: 0.2, animations: {
//					hudView.hide()
//					self.blurView.alpha = 0
//					self.view.layoutIfNeeded()
//				}, completion: { _ in
//					self.reset()
//					self.delegate?.requestWasSent(self, requestSuccess: true)
//				})
//				self.delegate?.didSelectTime(self, didAddShow: show)
//			} else {
//				print("boo")
//				UIView.animate(withDuration: 0.2, animations: {
//					hudView.hide()
//					self.blurView.alpha = 0
//					self.view.layoutIfNeeded()
//				})
//			}
//		})
//	}
