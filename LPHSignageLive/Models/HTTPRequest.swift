//
//  HTTP.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 05/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import Foundation

typealias sendData = (Bool) -> Void


class HTTPRequest {
	
	static let shared = HTTPRequest()
	
	var success: Bool?
	var time: Int?
	
	private init() {
	}
	
	enum Group: Int {
		case theatreOne = 0
		case theatreTwo = 1
		case theatreThree = 2
		case all = 3
		
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
	
	enum Interrupt: Int {
		case ten = 10
		case twenty = 20
		case thirty = 30
		case fire = 100
		
		var interrupt: Int {
			switch self {
			case .ten:
				return 4717
			case .twenty:
				return 4717
			case .thirty:
				return 4717
			case .fire:
				return 1
			}
		}
		
	}
	
	//Creates a url request dependant on the theatre selected and the page selected from
	func urlRequest(group: Group, interrupt: Interrupt) -> URLRequest {
		//get screen group to send message too
		let group = group.screenGroup
		let interrupt = interrupt.interrupt
		let time = getTime(time: interrupt)
		//set headers
		let header = [
			"X-SIGNAGELIVE-WBI-APP-ID": "6538d918-fc17-47d6-9394-605d115a95ec",
			"X-SIGNAGELIVE-WBI-APP-KEY": "2d7fe491-b147-4062-90e6-402d59438373",
			"Content-Type": "application/json",
			]
		//parameters to send - interrupt is the screen to show, player is specific player, group is all players in specific group
		let parameters = ["interrupt": interrupt, "players": [57599], "groups": [group], "additionalData": [["Key": "theatre", "value": String("\(group)")], ["Key": "time", "Value": time], ["Key": "action", "Value": "0"]]] as [String: AnyObject]
		let urlString = "https://wbtapi.signagelive.com/networks/15479/messages/"
		let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
		var request = URLRequest(url: URL(string: urlString)!)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = header
		request.httpBody = postData
		print(parameters)
		return request
	}
	
	
	//Helper function that will need changing!!!!
	func getTime(time: Int) -> String {
		switch time {
		case 10:
			return "10"
		case 20:
			return "20"
		case 30:
			return "30"
		default:
			return "1"
		}
	}
	
	
	func setTime(for group: Group, with interrupt: Interrupt, completion: @escaping sendData) {
		let url = urlRequest(group: group, interrupt: interrupt)
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard let response = response as? HTTPURLResponse, let data = data else {return}
			print("response is \(response)")
			print("returned data is \(data)")
			if response.statusCode == 201 {
				print("ok")
				self.success = true
			} else {
				print("Issue making connection")
			}
			DispatchQueue.main.async {
				completion(self.success ?? false)
			}
			} .resume()
	}
	
	
}
