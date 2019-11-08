//
//  Location+CoreDataProperties.swift
//  OneHourWalker
//
//  Created by Tyler Williams on 11/8/19.
//  Copyright © 2019 University of Kentucky. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var run: Run?

}
