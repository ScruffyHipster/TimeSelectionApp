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
	var activityIndicator: UIActivityIndicatorView?
	
	class func hud(inView view: UIView, animated: Bool) -> HUDView {
		let hudView = HUDView(frame: view.bounds)
		
		hudView.show(animated: animated)
		hudView.isOpaque = false
		view.addSubview(hudView)
		view.isUserInteractionEnabled = false
		
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
	
	func show(animated: Bool) {
		if animated {
			alpha = 0
			transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
			UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [], animations: {
				self.alpha = 1
				self.transform = CGAffineTransform.identity
			}, completion: nil)
			let container = self
			//indicator view
			self.activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
			guard let indicator = self.activityIndicator else {return}
			indicator.startAnimating()
			indicator.center = CGPoint(x: container.frame.width / 2, y: (container.frame.height / 2) - 8)
			container.addSubview(indicator)
		}
	}
	
	func hide() {
		superview?.isUserInteractionEnabled = true
		removeFromSuperview()
	}
}
