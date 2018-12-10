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
	@IBOutlet weak var textView: UITextView!
	
	//MARK:- Properties
	var http: HTTPRequest?
	var interrupt: HTTPRequest.Interrupt?
	var isTriggerSet: Bool?
	weak var delegate: EmergencyEventViewControllerProtocol?
	
	var http2: Httpv2?
	var interupt: Httpv2.Interrupt?
	var group: Httpv2.Group?
	var defaults: UserDefaults?
	
	var message = "Emergency"
	
	//MARK:- View did load
	override func viewDidLoad() {
		super.viewDidLoad()
		eventSwitch.addTarget(self, action: #selector(switchChanged), for: UISwitch.Event.valueChanged)
		navigationItem.title = "Emergency trigger"
		http = HTTPRequest.shared
		http2 = Httpv2.shared
		interupt = Httpv2.Interrupt.fire
		selectButton.isEnabled = false
		//sets value to the fire value
		let trigger = isTriggerSet ?? false
		flashView.backgroundColor = trigger ? UIColor.green : UIColor.red
		flashView.alpha = 0.2
		defaults = UserDefaults.standard
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		loadDefaults()
		let trigger = isTriggerSet ?? false
		flashView.backgroundColor = trigger ? UIColor.red : UIColor.green
		eventSwitch.isOn = trigger ? true : false
		heading.text = trigger ? "Emergency in progress" : message
		textView.alpha = trigger ? 0 : 1
	}
	
	func loadDefaults() {
		isTriggerSet = defaults?.bool(forKey: "isTriggerSet")
	}
	
	//MARK:- Actions
	@IBAction func didTapInitiateButton(_ sender: UIButton) {
		//unwraps value for use (set at 100 on view did load)
		let alert = UIAlertController(title: "Trigger Emergency Messaging", message: "Tap 'OK' to start emergency messaging on digital panels", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {(_) in
			let url = self.http2?.urlRequestSL(group: .all, interrupt: .fire)
			self.http2?.sendRequest(for: url!, completion: { (success) in
				if success {
					print("success")
					self.flashView.backgroundColor = UIColor.red
					self.isTriggerSet = success
					self.delegate?.didSetEmergencyEvent(self, didSetEvent: true)
					self.heading.text = """
					Emergency in
					progress
					"""
					self.selectButton.isEnabled = false
					self.textView.alpha = 0
					self.defaults?.set(self.isTriggerSet, forKey: "isTriggerSet")
				} else {
					self.isTriggerSet = success
					self.defaults?.set(self.isTriggerSet, forKey: "isTriggerSet")
					self.delegate?.didSetEmergencyEvent(self, didSetEvent: false)
				}
			})
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
			self.eventSwitch.isOn = false
			self.isTriggerSet = false
			self.defaults?.set(self.isTriggerSet, forKey: "isTriggerSet")
		}))
		present(alert, animated: true)
	}
	
	@objc func switchChanged(mySwitch: UISwitch) {
		let triggerSet = isTriggerSet ?? false
		
		if mySwitch.isOn {
			if !triggerSet {
				selectButton.isEnabled = true
				isTriggerSet = true
			}
		} else if !mySwitch.isOn {
			if triggerSet {
				let alert = UIAlertController(title: "Turn off", message: "Are you sure you want to turn off the emergency alert", preferredStyle: .actionSheet)
				alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (_) in
					let url = self.http2?.urlRequestSL(group: .all, interrupt: .cancel)
					self.http2?.sendRequest(for: url!, completion: { (success) in
						if success {
							self.flashView.backgroundColor = UIColor.green
							self.selectButton.isEnabled = false
							self.isTriggerSet = false
							self.textView.alpha = 1
							self.heading.text = self.message
							self.defaults?.set(self.isTriggerSet, forKey: "isTriggerSet")
							self.delegate?.didSetEmergencyEvent(self, didSetEvent: false)
						}
					})
				}))
				alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
					mySwitch.isOn = true
				}))
				present(alert, animated: true)
			}
		}
	}
}



//	override func viewDidAppear(_ animated: Bool) {
//		super.viewDidAppear(animated)
//		view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//		UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: UIView.AnimationOptions.curveEaseInOut, animations: {
//			self.vStack.center.y -= 20
//			self.view.transform = CGAffineTransform.identity
//			self.vStack.alpha = 1
//			self.flashView.alpha = 0.2
//			self.view.layoutIfNeeded()
//		},  completion: nil
//		)
//		UIView.animate(withDuration: 0.1) {
//			self.flashView.alpha = 0.2
//		}
//	}

//self.http?.setTime(for: .all, with: interrupt, completion: { (success) in
//				if success {
//					print("ok")
//					self.flashView.backgroundColor = UIColor.red
//					self.delegate?.didSetEmergencyEvent(self, didSetEvent: true)
//				} else {
//					print("non")
//					self.delegate?.didSetEmergencyEvent(self, didSetEvent: false)
//				}
//			})
