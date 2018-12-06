//
//  Show+CoreDataProperties.swift
//  LPHSignageLiveV1
//
//  Created by Tom Murray on 06/12/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//
//

import Foundation
import CoreData


extension Show {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Show> {
        return NSFetchRequest<Show>(entityName: "Show")
    }

    @NSManaged public var theatre: Int32
    @NSManaged public var theatreName: String?
    @NSManaged public var timeLabelTime: Int32
    @NSManaged public var timeToGo: Int32

}
