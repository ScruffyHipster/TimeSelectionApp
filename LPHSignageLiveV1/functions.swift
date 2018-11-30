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
