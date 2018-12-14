//
//  HTTPv2.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 06/12/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit


class Httpv2 {
	
	static let shared = Httpv2()
	
	var success: Bool?
	var time: String?
	
	
	
	private init() {
	}
	
	enum Group {
		case theatreOne
		case theatreTwo
		case theatreThree
		case all
		
		var screenGroup: Int {
			//return the screen group number
			switch self {
			case .theatreOne:
				return 1
			case .theatreTwo:
				return 2
			case .theatreThree:
				return 3
			case .all:
				return 4
			}
		}
	}
	
	enum Interrupt  {
		case ten
		case twenty
		case thirty
		case fire
		case cancel
		
		var interrupt: Int {
			switch self {
			case .ten:
				//Sends letter C
				return 4717
			case .twenty:
				//Sends letter C
				return 4717
			case .thirty:
				//Sends letter C
				return 4717
			case .fire:
				//sends letter F
				return 4720
			case .cancel:
				//sends letter X
				return 4738
			}
		}
		
	}
	
	//Helper function that will need changing!!!!
	func getTime(time: Interrupt) -> String {
		switch time {
		case .ten:
			return "600"
		case .twenty:
			return "1200"
		case .thirty:
			return "1800"
		default:
			return "2400"
		}
	}
	
	
	//creates a specific request for SL
	func urlRequestSL(group: Group, interrupt: Interrupt) -> URLRequest {
		
		let group = group.screenGroup
		let time = interrupt
		let interrupt = interrupt.interrupt
		
		var timeToUse: String?
		
		switch interrupt {
		case 4717:
			print("Creating a time related request")
		case 4720:
			print("Creating a fire request")
		case 4738:
			print("Creating a cancel whatevers on screen request")
		default:
			print("you should never see this message")
		}
		
		switch time {
		case .ten:
			timeToUse = "600"
		case .twenty:
			timeToUse = "1200"
		case .thirty:
			timeToUse = "1800"
		case .fire:
			timeToUse = ""
		case .cancel:
			timeToUse = ""
		}
		
		let additionalData = [["Key": "theatre", "value": String("\(group)")], ["Key": "time", "Value": timeToUse], ["Key": "action", "Value": "0"]]
		
		//these dont change
		let headers = [
			"X-SIGNAGELIVE-WBI-APP-ID": "6538d918-fc17-47d6-9394-605d115a95ec",
			"X-SIGNAGELIVE-WBI-APP-KEY": "2d7fe491-b147-4062-90e6-402d59438373",
			"Content-Type":"application/json",
		]
		
		let parameters = ["interrupt": interrupt, "players": [57599], "groups": [], "additionalData": [additionalData]] as [String: AnyObject]
		
		let urlString = "https://wbtapi.signagelive.com/networks/15479/messages/"
		let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
		var request = URLRequest(url: URL(string: urlString)!)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = headers
		request.httpBody = postData
		print(parameters)
		return request
	}
	

	
	
	func sendRequest(for urlRequest: URLRequest, completion: @escaping sendData) {
		let url = urlRequest
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard let response = response as? HTTPURLResponse else {return}
			if response.statusCode == 201 {
				//do something as data has been sent and received
				self.success = true
			} else if response.statusCode == 400 {
				  self.success = false
			} else {
				print("there was an issue")
				self.success = false
			}
			DispatchQueue.main.async {
				completion(self.success ?? false)
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
			}
		} .resume()
	}
	
}
