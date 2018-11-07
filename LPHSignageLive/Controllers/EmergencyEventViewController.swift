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

	var http: Htttp
	
    override func viewDidLoad() {
        super.viewDidLoad()
		eventSwitch.addTarget(self, action: #selector(switchChanged), for: UISwitch.Event.valueChanged)
	}
	
	@objc func switchChanged(mySwitch: UISwitch) {
		if mySwitch.isOn {
			selectButton.isEnabled = true
		} else {
			selectButton.isEnabled = false
		}
	}
	
	@IBAction func didTapInitiateButton(_ sender: UIButton) {
		let alert = UIAlertController(title: "action", message: "ok", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "ok", style: .destructive, handler: {(_) in
			
		}))
		alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { (_) in
			self.eventSwitch.isOn = false
	  }))
	}
}
