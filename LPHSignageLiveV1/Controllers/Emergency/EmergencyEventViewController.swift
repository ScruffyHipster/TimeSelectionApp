//
//  EmergencyEventViewController.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 07/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

protocol EmergencyEventViewControllerProtocol: class {
	func didSetEmergencyEvent(_ controller: EmergencyEventViewController, didSetEvent: Bool)
}

class EmergencyEventViewController: UIViewController {
	
	//MARK:- Outlets
	@IBOutlet weak var heading: UILabel!
	@IBOutlet weak var eventSwitch: UISwitch! {
		didSet {
			eventSwitch.transform = CGAffineTransform(scaleX: 2, y: 2)
		}
	}
	@IBOutlet weak var selectButton: UIButton!
	@IBOutlet weak var vStack: UIStackView!
	@IBOutlet weak var flashView: UIView!
	@IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var stackViewTrailingContstraint: NSLayoutConstraint!

	//MARK:- Properties
	var http: HTTPRequest?
	var interrupt: HTTPRequest.Interrupt?
	var isTriggerSet: Bool?
	weak var delegate: EmergencyEventViewControllerProtocol?
	
	//MARK:- View did load
    override func viewDidLoad() {
        super.viewDidLoad()
		eventSwitch.addTarget(self, action: #selector(switchChanged), for: UISwitch.Event.valueChanged)
		navigationItem.title = "Emergency trigger"
		http = HTTPRequest.shared
		selectButton.isEnabled = false
		//sets value to the fire value
		interrupt = HTTPRequest.Interrupt(rawValue: 100)
		flashView.backgroundColor = UIColor.green
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		vStack.center.y += 20
		vStack.alpha = 0
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
		UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: UIView.AnimationOptions.curveEaseInOut, animations: {
			self.vStack.center.y -= 20
			self.view.transform = CGAffineTransform.identity
			self.vStack.alpha = 1
			self.flashView.alpha = 0.2
			self.view.layoutIfNeeded()
		},  completion: nil
		)
		UIView.animate(withDuration: 0.1) {
			self.flashView.alpha = 0.2
		}
		
	}
	
	//MARK:- Actions
	@IBAction func didTapInitiateButton(_ sender: UIButton) {
		//unwraps value for use (set at 100 on view did load)
		guard let interrupt = interrupt else {return}
		let alert = UIAlertController(title: "Trigger Emergency Messaging", message: "Tap 'OK' to start emergency messaging on digital panels", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {(_) in
			self.http?.setTime(for: .all, with: interrupt, completion: { (success) in
				if success {
					print("ok")
					self.flashView.backgroundColor = UIColor.red
					self.delegate?.didSetEmergencyEvent(self, didSetEvent: true)
				} else {
					print("non")
					self.delegate?.didSetEmergencyEvent(self, didSetEvent: false)
				}
			})
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
			self.eventSwitch.isOn = false
		}))
		present(alert, animated: true
		)
	}
	
	@objc func switchChanged(mySwitch: UISwitch) {
		if mySwitch.isOn {
			selectButton.isEnabled = true
			isTriggerSet = true
		} else {
			selectButton.isEnabled = false
			isTriggerSet = false
		}
	}
	

}
