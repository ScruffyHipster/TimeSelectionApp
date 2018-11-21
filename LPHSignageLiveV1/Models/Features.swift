//
//  MainCell.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 31/10/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class Features {
	var title: String
	var image: String
	var category: String
	var accessedAmount: Int?
	
	
	init(title: String, image: String, category: String) {
		self.title = title
		self.image = image
		self.category = category
	}
}
