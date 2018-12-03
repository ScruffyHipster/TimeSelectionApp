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
	var timer: Timer?
	
	
	init(timeToGo: Int, theatreName: TheatreSelectionName, theatre: Int) {
		self.timeToGo = timeToGo
		self.theatre = theatre
		self.theatreName = theatreName
	}
	
	
	
	
	
}
