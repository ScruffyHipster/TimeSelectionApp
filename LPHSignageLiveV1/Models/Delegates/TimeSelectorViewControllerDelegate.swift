//
//  TimeSelecorViewControllerDelegate.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 21/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit


protocol TimeSelectorViewControllerDelegate: class {
	
	func didSelectTime(_ controller: TimeSelectorViewController, timeSelected time: Double)

}
