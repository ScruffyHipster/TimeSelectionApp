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
	
	 enum Theatre: Int {
		case theatreOne = 0
		case theatreTwo = 1
		case theatreThree = 2
		
		var type: Int {
			switch self {
			case .theatreOne:
				return 1
			case .theatreTwo:
				return 2
			case .theatreThree:
				return 3
			}
		}
	}
	
	 enum Interrupt: Int {
		case time = 0
		case fire = 1
	}
	
	//Creates a url request dependant on the theatre selected and the page selected from
	 func urlRequest(category: Theatre, time: Double, interrupt: Interrupt) -> URLRequest {
		let theatre = category.type
		let header = [
			"X-SIGNAGELIVE-WBI-APP-ID": "acb2443a-e82a-4790-aa23-cd5b6611aca1",
			"X-SIGNAGELIVE-WBI-APP-KEY": "2988ae91-7f41-4995-b627-e57085a6a78b",
			"Content-Type": "application/json",
			"cache-control": "no-cache"
		]
		let parameters = ["interrupt": interrupt.rawValue, "players": [], "groups": [theatre]] as [String: AnyObject]
		let urlString = "https://wbtapi.signagelive.com/networks/14103/messages/"
		let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
		var request = URLRequest(url: URL(string: urlString)!)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = header
		request.httpBody = postData
		print(parameters)
		return request
	}

	
	func setTime(for theatre: Theatre, in time: Double, with interrupt: Interrupt, completion: @escaping sendData) {
		let url = urlRequest(category: theatre, time: time, interrupt: interrupt)
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard let response = response as? HTTPURLResponse else {return}
			print("response is \(response)")
				if response.statusCode == 201 {
				print("ok")
			    self.success = true
			} else {
				print("Issue making connection")
			    self.success = false
			}
			DispatchQueue.main.async {
				completion(self.success ?? false)
			}
		} .resume()
	}
	
	
}
