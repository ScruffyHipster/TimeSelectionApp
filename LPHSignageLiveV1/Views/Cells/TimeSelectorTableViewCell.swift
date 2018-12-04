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
	
	
	override func prepareForReuse() {
		super.prepareForReuse()
	}
	
	//Configures the cell
	func configureCell(_ cell: TimeSelectorTableViewCell, withShow show: Show) {
		//gets the name of the theatre for the label
		switch show.theatreName {
		case .quarryTheatre:
			self.theatreLabel.text = "Quarry"
		case .theatre2:
			self.theatreLabel.text = "Theatre 2"
		case .theatre3:
			self.theatreLabel.text = "Theatre 3"
		case .noTheatre:
			break
		}
		configureTimeLabel(with: show.timeToGo, for: timeLabel)
	}
	
	deinit {
		print("\(timeLabel.text) has been removed")
	}
	

}
