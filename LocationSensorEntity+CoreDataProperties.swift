//
//  LocationSensorEntity+CoreDataProperties.swift
//  
//
//  Created by Kseniia Shkurenko on 25.10.2020.
//
//

import Foundation
import CoreData


extension LocationSensorEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationSensorEntity> {
        return NSFetchRequest<LocationSensorEntity>(entityName: "LocationSensorEntity")
    }

    @NSManaged public var altitude: Float
    @NSManaged public var date: Date?
    @NSManaged public var latitude: Float
    @NSManaged public var longtitude: Float

}
