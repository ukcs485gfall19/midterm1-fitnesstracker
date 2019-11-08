//
//  Run+CoreDataProperties.swift
//  OneHourWalker
//
//  Created by Tyler Williams on 11/8/19.
//  Copyright © 2019 University of Kentucky. All rights reserved.
//
//

import Foundation
import CoreData


extension Run {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Run> {
        return NSFetchRequest<Run>(entityName: "Run")
    }

    @NSManaged public var distance: Double
    @NSManaged public var duration: Int16
    @NSManaged public var timestamp: Date?
    @NSManaged public var locations: Location?

}
