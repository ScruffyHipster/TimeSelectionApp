//
//  HUDView.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 07/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class HUDView: UIView {

	var text: String = "Hello"
	
	class func hud(inView view: UIView, animated: Bool) -> HUDView {
		var activityIndicator: UIActivityIndicatorView?
		let hudView = HUDView(frame: view.bounds)
		let width = view.bounds.width
		let height = view.bounds.height
		
		hudView.isOpaque = false
		view.addSubview(hudView)
		view.isUserInteractionEnabled = false
		
		//indicator view
		activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
		guard let indicator = activityIndicator else {return hudView}
		indicator.startAnimating()
		indicator.center = CGPoint(x: width / 2, y: (height / 2) - 8)
		view.addSubview(indicator)
		
		return hudView
	}
	
	override func draw(_ rect: CGRect) {
		//create a box
		let boxwidth: CGFloat = 140
		let boxHeight: CGFloat = 140
		
		//set the corners of the box to be rounded
		let boxRect = CGRect(x: round((bounds.size.width - boxwidth) / 2), y: round((bounds.size.height - boxHeight) / 2), width: boxwidth, height: boxHeight)
		let roundRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
		//set colour to a light gray
		UIColor(white: 0.3, alpha: 0.8).setFill()
		roundRect.fill()
		
		//Text attrbutes and draw
		let attribtues = [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Regular", size: 16), NSAttributedString.Key.foregroundColor: UIColor.white]
		let textSize = text.size(withAttributes: attribtues as [NSAttributedString.Key : Any])
		let textPoint = CGPoint(x: center.x - round(textSize.width / 2), y: center.y - round(textSize.height / 2) + boxHeight / 4)
		text.draw(at: textPoint, withAttributes: attribtues as [NSAttributedString.Key : Any])
	}
	
}
