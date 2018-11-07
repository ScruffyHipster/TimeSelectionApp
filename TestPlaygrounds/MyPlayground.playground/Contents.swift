import UIKit

var str = "Hello, playground"



struct http {
	lazy var decoder: JSONDecoder = {
		var d = JSONDecoder()
		return d
	}()
	
	
	
	var header = ["X-SIGNAGELIVE-WBI-APP-ID": "acb2443a-e82a-4790-aa23-cd5b6611aca1",
				  "X-SIGNAGELIVE-WBI-APP-KEY": "2988ae91-7f41-4995-b627-e57085a6a78b",
				  "Content-Type": "application/json",
				  "cache-control": "no-cache"]
	
	
	func makeRequest() {
		var url = URLRequest(url: URL(string: "https://wbtapi.signagelive.com/networks/14103/players/")!)
		//guard let url = urlString else {return}
		url.allHTTPHeaderFields = header
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard let data = data else {return}
			guard let response = response as? HTTPURLResponse else {return}
			if response.statusCode == 200 {
				print("made a connection")
				print(data)
			} else if response.statusCode == 400 {
				print("failed to make a connection")
			}
		} .resume()
		
	}
}


var i = http()
i.makeRequest()
