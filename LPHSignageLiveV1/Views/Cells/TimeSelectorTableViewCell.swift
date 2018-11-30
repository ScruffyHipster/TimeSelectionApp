//
//  TimeSelectorCell.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 27/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class TimeSelectorTableViewCell: UITableViewCell {
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var theatreLabel: UILabel!
	
	var timer: Timer?
	var timeToSet: Int = 0
	var interval: TimeInterval?
	var startTime = Date().timeIntervalSinceNow
	
	override func prepareForReuse() {
		super.prepareForReuse()
		timer?.invalidate()
	}
	
	//Configures the cell
	func configureCell(_ cell: TimeSelectorTableViewCell, withShow show: Show) {
		timeToSet = show.timeToGo
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCountdown), userInfo: nil, repeats: true)
		
		switch show.theatre {
		case 0:
			self.theatreLabel.text = "Quarry"
		case 1:
			self.theatreLabel.text = "Theatre 2"
		case 2:
			self.theatreLabel.text = "Theatre 3"
		default:
			break
		}
	}
	
	deinit {
		timer?.invalidate()
	}
	
	@objc func updateCountdown() {
		
		
		guard let timer = timer else {return}
		
		//MARK:-TODO add functionailty to allow for multiple independant times to be ran
		
		timeToSet -= 1
		
		if timeToSet > 0 {
			configureTimeLabel(with: timeToSet, for: timeLabel)
		} else {
			timer.invalidate()
			timeLabel.text = "00:00"
		}
	}
	
}
