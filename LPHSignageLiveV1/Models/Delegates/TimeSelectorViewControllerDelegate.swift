//
//  TimeSelecorViewControllerDelegate.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 21/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit


protocol TimeSelectorViewControllerDelegate: class {
	
	//MARK:- functions to set the time and theatre selected
	func didSelectTime(_ controller: TimeSelectorViewController, timeSelected time: Double, theatreSelected: Int)
	
	//MARK:- use function to dismiss the child view controller on successful sent request
	func requestWasSent(_ controller: TimeSelectorViewController, requestSuccess succes: Bool)
}
