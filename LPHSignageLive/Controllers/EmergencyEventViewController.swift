//
//  EmergencyEventViewController.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 07/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class EmergencyEventViewController: UIViewController {
	
	@IBOutlet weak var eventSwitch: UISwitch!
	@IBOutlet weak var selectButton: UIButton!

	var http: HTTPRequest?
	var interrupt: HTTPRequest.Interrupt?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		eventSwitch.addTarget(self, action: #selector(switchChanged), for: UISwitch.Event.valueChanged)
		http = HTTPRequest.shared
		selectButton.isEnabled = false
		//sets value to the fire value
		interrupt = HTTPRequest.Interrupt(rawValue: 100)
	}
	
	@objc func switchChanged(mySwitch: UISwitch) {
		if mySwitch.isOn {
			selectButton.isEnabled = true
		} else {
			selectButton.isEnabled = false
		}
	}
	
	@IBAction func didTapInitiateButton(_ sender: UIButton) {
		//unwraps value for use (set at 100 on view did load)
		guard let interrupt = interrupt else {return}
		let alert = UIAlertController(title: "Trigger Emergency Messaging", message: "Tap 'OK' to start emergency messaging on digital panels", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {(_) in
			self.http?.setTime(for: .all, with: interrupt, completion: { (success) in
				if success {
					print("ok")
				} else {
					print("non")
				}
			})
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
			self.eventSwitch.isOn = false
	  }))
		present(alert, animated: true
		)
	}
}
