//
//  functions.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 30/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit


//************Helper Functions*************//
func createAlert(title: String, message: String, buttonTitle: String) -> UIAlertController {
	let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
	alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
	return alert
}

public func configureTimeLabel(with time: Int32, for label: UILabel) {
	
	let minutes = time / 60 % 60
	let seconds = time % 60
	
	label.text = String(format: "%02i:%02i", minutes, seconds)
	
	 
}

public func selectTheatre(for theatre: Int) -> String {
	var name = ""
	switch theatre {
	case 0:
		name =  "Quarry Theatre"
		break
	case 1:
		name = "Theatre 2"
		break
	case 2:
		name = "Theatre 3"
		break
	default:
		break
	}
	return name
}

//*********Core Data Helpers***************//
let coreDataSaveFailedNotification = Notification.Name(rawValue: "CoreDataSaveFailedNotification")

func fataCoreDataError(error: Error) {
	print("*** Fatal error \(error) ***")
	NotificationCenter.default.post(name: coreDataSaveFailedNotification, object: nil)
}

let applicationDirectory: URL = {
	let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	return url[0]
}()
