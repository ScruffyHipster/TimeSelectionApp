//
//  functions.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 30/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

public func configureTimeLabel(with time: Int, for label: UILabel) {
	
	let minutes = time / 60 % 60
	let seconds = time % 60
	
	label.text = String(format: "%02i:%02i", minutes, seconds)
	
	 
}

public func selectTheatre(for theatre: Int) -> String {
	var name = ""
	switch theatre {
	case 0:
		name =  "Quarry Theatre"
		break
	case 1:
		name = "Theatre 2"
		break
	case 2:
		name = "Theatre 3"
		break
	default:
		break
	}
	return name
}

let applicationDirectory: URL = {
	let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	return url[0]
}()
