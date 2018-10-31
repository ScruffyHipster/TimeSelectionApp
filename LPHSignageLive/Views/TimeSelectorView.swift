//
//  TimeSelectorView.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 31/10/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit
import MSCircularSlider

class TimeSelectorView: UIView {
	
	@IBOutlet weak var sliderView: UIView!
	@IBOutlet weak var timeLabel: UILabel!
	
	
	//Slider properties
	lazy var slider: MSCircularSlider? = {
		let slider = MSCircularSlider()
		slider.filledColor = .blue
		slider.unfilledColor = .yellow
		slider.handleType = .doubleCircle
		slider.minimumValue = 5
		slider.maximumValue = 30
		slider.maximumAngle = 300
		slider.currentValue = 5
		slider.labels = ["5", "10", "30"]
		return slider
	}()

}
