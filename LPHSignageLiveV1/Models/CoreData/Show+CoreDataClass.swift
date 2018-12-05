//
//  Show+CoreDataClass.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 05/12/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Show)
public class Show: NSManagedObject {
	deinit {
		print("\(theatreName) has now been deallocated")
	}
}
