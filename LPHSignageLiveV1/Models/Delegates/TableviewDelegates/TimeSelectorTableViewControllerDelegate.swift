//
//  TimeSelectorTableViewControllerDelegate.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 27/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit


class TimeSelectorTableViewDatasource: NSObject, UITableViewDataSource {
	
	var shows = [Show]()
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return shows.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell") as! TimeSelectorTableViewCell
		switch shows[indexPath.row].theatre {
		case 0:
			cell.theatreLabel.text = "Quarry"
		case 1:
			cell.theatreLabel.text = "Theatre 2"
		case 2:
			cell.theatreLabel.text = "Theatre 3"
		default:
			break
		}
		
		cell.timeLabel.text = String("\(shows[indexPath.row].timeToGo)")
		return cell
	}
}

extension TimeSelectorTableViewDatasource: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.frame.height / 3
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.frame.height / 3
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		//TODO: add way of removing the timers
	}
}
