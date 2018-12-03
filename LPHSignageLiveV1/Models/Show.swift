//
//  Time.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 27/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import Foundation


class Show {
	
	var timeToGo: Int
	var theatreName: TheatreSelectionName
	var theatre: Int
	
	//Timer properties
	var timer: Timer?
	var timeLabelTime: Int?
	
	init(timeToGo: Int, theatreName: TheatreSelectionName, theatre: Int) {
		self.timeToGo = timeToGo
		self.theatre = theatre
		self.theatreName = theatreName
	}

	func startTimer() {
		print("timer started on \(theatreName)")
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
			self.timeToGo -= 1
			if self.timeToGo > 0 {
				self.timeLabelTime = self.timeToGo
				print("time to go is \(self.timeToGo) for \(self.theatreName)")
			} else if self.timeToGo <= 0 {
				self.timer!.invalidate()
			}})
	}
}
