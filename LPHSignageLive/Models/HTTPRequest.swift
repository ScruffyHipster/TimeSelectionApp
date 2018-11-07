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
	
	private init() {
	}
	
	 enum Group: Int {
		case theatreOne = 1
		case theatreTwo = 2
		case theatreThree = 3
		case all = 4
		
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
				return 1
			case .twenty:
				return 2
			case .thirty:
				return 3
			case .fire:
				return 4
			}
		}
	}
	
	//Creates a url request dependant on the theatre selected and the page selected from
	 func urlRequest(group: Group, interrupt: Interrupt) -> URLRequest {
		//get screen group to send message too
		let group = group.screenGroup
		let interrupt = interrupt.interrupt
		//set headers
		let header = [
			"X-SIGNAGELIVE-WBI-APP-ID": "acb2443a-e82a-4790-aa23-cd5b6611aca1",
			"X-SIGNAGELIVE-WBI-APP-KEY": "2988ae91-7f41-4995-b627-e57085a6a78b",
			"Content-Type": "application/json",
			"cache-control": "no-cache"
		]
		//parameters to send - interrupt is the screen to show, player is specific player, group is all players in specific group
		let parameters = ["interrupt": interrupt, "players": [], "groups": [group]] as [String: AnyObject]
		let urlString = "https://wbtapi.signagelive.com/networks/14103/messages/"
		let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
		var request = URLRequest(url: URL(string: urlString)!)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = header
		request.httpBody = postData
		print(parameters)
		return request
	}

	
	func setTime(for group: Group, with interrupt: Interrupt, completion: @escaping sendData) {
		let url = urlRequest(group: group, interrupt: interrupt)
	    URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard let response = response as? HTTPURLResponse else {return}
			print("response is \(response)")
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
