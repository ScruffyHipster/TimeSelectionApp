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
	var timeToSet: Int?
	
	//Configures the cell
	func configureCell(_ cell: TimeSelectorTableViewCell, withShow show: Show) {
		timeToSet = 0
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
	
	@objc func updateCountdown() {
		print("here")
		timeToSet! -= 1
		if timeToSet! > 0 {
			let minutes = timeToSet! / 60 % 60
			let seconds = timeToSet! % 60
			//Formats the time into a string
			timeLabel.text = String(format: "%02i:%02i", minutes, seconds)
		} else {
			timer?.invalidate()
			timeLabel.text = ""
		}
	}
	
}
