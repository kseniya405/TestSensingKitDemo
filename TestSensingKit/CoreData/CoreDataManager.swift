//
//  CoreDataManager.swift
//  TestSensingKit
//
//  Created by Kseniia Shkurenko on 24.10.2020.
//

import Foundation
import CoreData
import CoreLocation
import CoreMotion

class CoreDataManager {
    let persistentContainer = NSPersistentContainer(name: "LocationModel")
    
    var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    var stackInitialized = false
    
    static let shared = CoreDataManager()
    
    func initalizeStackIfNeeded() {
        if !stackInitialized {
            self.persistentContainer.loadPersistentStores { description, error in
                if let error = error {
                    print("could not load store \(error.localizedDescription)")
                    return
                }
                self.stackInitialized = true
                print("store loaded")
            }
        }
    }
    
    func insertLocation(_ locationObject: CLLocation) throws {
        let location = LocationSensorEntity(context: self.context)
        location.latitude = Float(locationObject.coordinate.latitude)
        location.longtitude = Float(locationObject.coordinate.longitude)
        location.altitude = Float(locationObject.altitude)
        location.date = Date()
        
        self.context.insert(location)
        try self.context.save()
    }
    
    func fetchLocations() throws -> [LocationSensorEntity] {
        return try self.context.fetch(LocationSensorEntity.fetchRequest() as NSFetchRequest<LocationSensorEntity>)
    }
    
    func deleteLocations() throws {
        let fetchRequest = LocationSensorEntity.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try self.context.execute(deleteRequest)
        try self.context.save()
    }
    
    func getLastLocation() throws -> [LocationSensorEntity] {
        let fetchRequest = LocationSensorEntity.fetchRequest() as NSFetchRequest<LocationSensorEntity>
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = 1
        return try self.context.fetch(fetchRequest)
    }
    
    func insertGyro(_ data: CMGyroData) throws {
        let gyro = GyroscopeSensorEntity(context: self.context)
        gyro.x = Float(data.rotationRate.x)
        gyro.y = Float(data.rotationRate.y)
        gyro.z = Float(data.rotationRate.z)
        gyro.date = Date()
        
        self.context.insert(gyro)
        try self.context.save()
    }
    
    func fetchGyro() throws -> [GyroscopeSensorEntity] {
        return try self.context.fetch(GyroscopeSensorEntity.fetchRequest() as NSFetchRequest<GyroscopeSensorEntity>)
    }
    
    func deleteGyro() throws {
        let fetchRequest = GyroscopeSensorEntity.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try self.context.execute(deleteRequest)
        try self.context.save()
    }
    
    func getLastGyro() throws -> [GyroscopeSensorEntity] {
        let fetchRequest = GyroscopeSensorEntity.fetchRequest() as NSFetchRequest<GyroscopeSensorEntity>
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = 1
        return try self.context.fetch(fetchRequest)
    }
    
    func insertAccelerometer(_ data: CMAccelerometerData) throws {
        let accelerometer = AccelerometerSensorEntity(context: self.context)
        accelerometer.x = Float(data.acceleration.x)
        accelerometer.y = Float(data.acceleration.y)
        accelerometer.z = Float(data.acceleration.z)
        accelerometer.date = Date()
        
        self.context.insert(accelerometer)
        try self.context.save()
    }
    
    func fetchAccelerometer() throws -> [AccelerometerSensorEntity] {
        return try self.context.fetch(AccelerometerSensorEntity.fetchRequest() as NSFetchRequest<AccelerometerSensorEntity>)
    }
    
    func deleteAccelerometer() throws {
        let fetchRequest = AccelerometerSensorEntity.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try self.context.execute(deleteRequest)
        try self.context.save()
    }
    
    func getLastAccelerometer() throws -> [AccelerometerSensorEntity] {
        let fetchRequest = AccelerometerSensorEntity.fetchRequest() as NSFetchRequest<AccelerometerSensorEntity>
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = 1
        return try self.context.fetch(fetchRequest)
    }
    
    func insertMagnetometer(_ data: CMMagnetometerData) throws {
        let magnetometer = MagnetometerSensorEntity(context: self.context)
        magnetometer.x = Float(data.magneticField.x)
        magnetometer.y = Float(data.magneticField.y)
        magnetometer.z = Float(data.magneticField.z)
        magnetometer.date = Date()
        
        self.context.insert(magnetometer)
        try self.context.save()
    }
    
    func fetchMagnetometer() throws -> [MagnetometerSensorEntity] {
        return try self.context.fetch(MagnetometerSensorEntity.fetchRequest() as NSFetchRequest<MagnetometerSensorEntity>)
    }
    
    func deleteMagnetometer() throws {
        let fetchRequest = MagnetometerSensorEntity.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try self.context.execute(deleteRequest)
        try self.context.save()
    }
    
    func getLastMagnetometer() throws -> [MagnetometerSensorEntity] {
        let fetchRequest = MagnetometerSensorEntity.fetchRequest() as NSFetchRequest<MagnetometerSensorEntity>
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = 1
        return try self.context.fetch(fetchRequest)
    }
}
