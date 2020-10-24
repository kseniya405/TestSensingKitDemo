//
//  MagnetometerSensorEntity+CoreDataProperties.swift
//  
//
//  Created by Kseniia Shkurenko on 24.10.2020.
//
//

import Foundation
import CoreData


extension MagnetometerSensorEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MagnetometerSensorEntity> {
        return NSFetchRequest<MagnetometerSensorEntity>(entityName: "MagnetometerSensorEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var x: Float
    @NSManaged public var y: Float
    @NSManaged public var z: Float

}
