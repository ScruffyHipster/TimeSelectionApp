//
//  Time.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 27/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import Foundation


extension Show {

//	var timeToGo: Int
//	var theatreName: TheatreSelectionName
//	var theatre: Int
//
//	//Timer properties
//	var timer: Timer?
//	var timeLabelTime: Int?

//	convenience init(timeToGo: Int32, theatreName: TheatreSelectionName, theatre: Int32) {
//		self.timeToGo = timeToGo
//		self.theatre = theatre
//		self.theatreName = theatreName
//	}


//	required convenience init?(coder aDecoder: NSCoder) {
//		let timeToGo = aDecoder.decodeInteger(forKey: "timeToGo")
//		let theatre = aDecoder.decodeInteger(forKey: "theatre")
//		let theatreName = aDecoder.decodeObject(forKey: "theatreName") as! TheatreSelectionName
//		self.init(timeToGo: timeToGo, theatreName: theatreName, theatre: theatre)
//	}
//
//
//	func encode(with aCoder: NSCoder) {
//		aCoder.encode(timeToGo, forKey: "timeToGo")
//		aCoder.encode(theatre, forKey: "theatre")
//		aCoder.encode(theatreName, forKey: "theatreName")
//	}

	func startTimer() {
		print("timer started on \(theatreName)")
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
			self.timeToGo -= 1
			if self.timeToGo > 0 {
				self.timeLabelTime = self.timeToGo
				print("time to go is \(self.timeToGo) for \(self.theatreName)")
			} else if self.timeToGo == 0 {
				self.timer!.invalidate()
			}})
	}

}
