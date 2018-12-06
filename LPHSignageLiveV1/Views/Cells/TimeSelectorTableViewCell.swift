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
	
	override func prepareForReuse() {
	    super.prepareForReuse()
		timer?.invalidate()
	}
	
	//Configures the cell
	func configureCell(_ cell: TimeSelectorTableViewCell, withShow show: Show) {
		//gets the name of the theatre for the label
		switch show.theatreName {
		case "Quarry Theatre":
			self.theatreLabel.text = "Quarry"
		case "Theatre two":
			self.theatreLabel.text = "Theatre 2"
		case "Theatre three":
			self.theatreLabel.text = "Theatre 3"
		case "Select Theatre":
			break
		default:
			break
		}
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
			configureTimeLabel(with: show.timeToGo, for: self.timeLabel)
		})
	}
	
	deinit {
		if timer?.isValid ?? false {
			timer?.invalidate()
		}
		print("tableview cell has been removed. This cell contained")
	}
}
