//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Griffin Healy on 1/24/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var locationName: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged var date: Date
    @NSManaged public var locationDescription: String
    @NSManaged public var category: String
    @NSManaged var placemark: CLPlacemark?
    @NSManaged public var photoID: NSNumber? // int 32, but NSNUmber is how objc handles numbers


}
