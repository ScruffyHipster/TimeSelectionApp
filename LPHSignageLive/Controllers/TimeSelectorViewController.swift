//
//  TimeSelectorViewController.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 31/10/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit
import MSCircularSlider

class TimeSelectorViewController: UIViewController {
	
	//MARK:- Outlets
	@IBOutlet weak var timeView: TimeSelectorView!
	@IBOutlet var sliderView: MSCircularSlider!
	@IBOutlet weak var theatreSelection: UISegmentedControl!
	@IBOutlet weak var resetButton: UIButton!
	@IBOutlet weak var selectTimeButton: UIButton!
	@IBOutlet weak var timeLabel: UILabel! {
		didSet {
			timeLabel.text = String("\(Int(0))")
		}
	}
	
	//MARK:- Actions
	@IBAction func resetTimer(_ sender: Any) {
		if sliderView.currentValue != 0 {
			sliderView.currentValue = 0
		}
	}
	@IBAction func selectLabelTapped(_ sender: UIButton) {
		sendTime()
	}
	
	
	//MARK:- Properties
	var timeToSend: Double?
	var theatre: Int? {
		get {
			return theatreSelection?.selectedSegmentIndex
		}
	}
	
	var httpRequest: HTTPRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
		sliderView.delegate = self
		selectTimeButton.isEnabled = false
		httpRequest = HTTPRequest.shared
		navigationItem.title = "Time selector"
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
}

extension TimeSelectorViewController {
	//MARK:- http methods
	func sendTime() {
		guard let theatre = theatre else {return}
		guard let category = HTTPRequest.Theatre(rawValue: theatre) else {return}
		httpRequest?.setTime(for: category, in: sliderView.currentValue, with: .time, completion: { (success) in
			if success == true {
				print("yay")
			} else {
				print("boo")
			}
		})
	}
}

extension TimeSelectorViewController: MSCircularSliderDelegate {
	
	//MARK:- Delegate functions
	func circularSlider(_ slider: MSCircularSlider, valueChangedTo value: Double, fromUser: Bool) {
		
		//TODO:- sort this out below!
		if sliderView.currentValue == 10.0 {
			timeView.timeLabel.text = String("\(Int(value))")
		} else if sliderView.currentValue == 20.0 {
			timeView.timeLabel.text = String("\(Int(value))")
		} else if sliderView.currentValue == 30.0 {
			timeView.timeLabel.text = String("\(Int(value))")
		} else {
			timeView.timeLabel.text = "0"
		}
		
		if value == 0 {
			selectTimeButton.isEnabled = false
		} else if value > 0
		{
			selectTimeButton.isEnabled = true
		}
		print(value)
	}
	
	func circularSlider(_ slider: MSCircularSlider, startedTrackingWith value: Double) {
		//Optional
	}
	
	func circularSlider(_ slider: MSCircularSlider, endedTrackingWith value: Double) {
		//Optional
	}
}
