//
//  Time.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 27/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import Foundation


extension Show {

	//starts the show timer
	func startTimer() {
		print("timer started on \(String(describing: theatreName))")
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
			self.timeToGo -= 1
			if self.timeToGo > 0 {
				self.timeLabelTime = self.timeToGo
				print("time to go is \(self.timeToGo) for \(String(describing: self.theatreName))")
			} else if self.timeToGo == 0 {
				self.timer!.invalidate()
			}})
	}

}
