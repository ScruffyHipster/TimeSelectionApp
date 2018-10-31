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
	
	@IBOutlet weak var timeView: TimeSelectorView!

    override func viewDidLoad() {
        super.viewDidLoad()
		setupView()
    }
	
	func setupView() {
		timeView.slider?.delegate = self
		timeView.slider = MSCircularSlider(frame: timeView.sliderView.frame)
	}

}

extension TimeSelectorViewController: MSCircularSliderDelegate {
	//MARK:- Delegate functions
	func circularSlider(_ slider: MSCircularSlider, valueChangedTo value: Double, fromUser: Bool) {
		timeView.timeLabel.text = String(value)
		print(value)
	}
	
	func circularSlider(_ slider: MSCircularSlider, startedTrackingWith value: Double) {
		//Optional
	}
	
	func circularSlider(_ slider: MSCircularSlider, endedTrackingWith value: Double) {
		//Optional
	}
}
