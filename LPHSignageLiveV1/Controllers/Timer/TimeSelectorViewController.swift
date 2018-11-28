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
		sendTime()
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
	var httpRequest: HTTPRequest?
	var interrupt: HTTPRequest.Interrupt?
	var reachability = Reachability()
	weak var delegate: TimeSelectorViewControllerDelegate?
	var defaults: UserDefaults?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		selectTimeButton.isEnabled = false
		sliderView.delegate = self
		httpRequest = HTTPRequest.shared
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
	
	func sendTime() {
		UIView.animate(withDuration: 0.2) {
			self.blurView.alpha = 1
			self.view.layoutIfNeeded()
		}
		//hudView with spinning animator
		let hudView = HUDView.hud(inView: (navigationController?.view)!, animated: true)
		hudView.text = "Sending request"
		//unwraps options theatre screens first
		guard let theatre = theatre else {return}
		//gets the time to send from the slider view
		guard let interrupt = HTTPRequest.Interrupt(rawValue: timeToSend) else {return}
		//gets the group from the segmented selection using the unwrapped var above
		guard let group = HTTPRequest.Group(rawValue: theatre) else {return}
		httpRequest?.setTime(for: group, with: interrupt, completion: { (success) in
			if success == true {
				print("yay")
				UIView.animate(withDuration: 0.2, animations: {
					hudView.hide()
					self.blurView.alpha = 0
					self.view.layoutIfNeeded()
				}, completion: { _ in
					self.reset()
					self.delegate?.requestWasSent(self, requestSuccess: success)
				})
				let show = Show(timeToGo: Int(self.countDownTime(self.timeToSend)), theatre: theatre)
				self.delegate?.didSelectTime(self, didAddShow: show)
			} else {
				print("boo")
				UIView.animate(withDuration: 0.2, animations: {
					hudView.hide()
					self.blurView.alpha = 0
					self.view.layoutIfNeeded()
				})
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
