//
//  GyroscopeSensorEntity+CoreDataProperties.swift
//  
//
//  Created by Kseniia Shkurenko on 25.10.2020.
//
//

import Foundation
import CoreData


extension GyroscopeSensorEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GyroscopeSensorEntity> {
        return NSFetchRequest<GyroscopeSensorEntity>(entityName: "GyroscopeSensorEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var x: Float
    @NSManaged public var y: Float
    @NSManaged public var z: Float

}
