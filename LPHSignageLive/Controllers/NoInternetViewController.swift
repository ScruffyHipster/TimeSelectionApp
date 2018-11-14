//
//  NoInternetViewController.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 14/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit
import Reachability

class NoInternetViewController: UIViewController {
	
	//MARK:- Outlets
	
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			let label = titleLabel
				label?.text = "No Internet Connection"
				label!.textAlignment = .center
			}
		}
	
	@IBOutlet weak var messageLabel: UILabel! {
		didSet {
			let message = messageLabel
			message?.text = """
			This app requires an internet connection to function.
			
			Please close the app, ensure you have an internet connection
			and re open the app.
			"""
			message?.textAlignment = .center
			message?.textColor = UIColor.gray
		}
	}
	@IBOutlet weak var imageWifi: UIImageView! {
		didSet {
			let image = imageWifi
			image?.image = UIImage(named: "wifi-signal")
		}
	}
	
	//MARK:-Properties
	var reachability: Reachability? = nil
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destination.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
