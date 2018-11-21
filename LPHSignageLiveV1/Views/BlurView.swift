//
//  BlurView.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 16/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class BlurView: UIView {

	//blur
	let blur = UIBlurEffect(style: .light)
	
	
	override func draw(_ rect: CGRect) {
		let height = CGFloat(500)
		let width = CGFloat(500)
		
		let blurView = UIVisualEffectView(effect: blur)
		let rect = CGRect(x: 0, y: 0, width: width, height: height)
		blurView.contentView
	}

}
