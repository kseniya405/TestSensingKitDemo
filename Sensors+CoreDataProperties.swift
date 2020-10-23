//
//  Sensors+CoreDataProperties.swift
//  TestSensingKit
//
//  Created by Kseniia Shkurenko on 23.10.2020.
//

import Foundation
import CoreData
import CoreLocation

extension Sensors {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Sensors")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: Date
    @NSManaged public var locationDescription: String
    @NSManaged public var category: String
    @NSManaged public var placemark: CLPlacemark?

}
