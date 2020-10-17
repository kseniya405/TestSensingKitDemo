//
//  AppDelegate.swift
//  CoreLocationTest
//
//  Created by Ксения Шкуренко on 11.10.2020.
//

import UIKit
import CoreData
import CoreLocation
import CoreMotion

fileprivate let fileName = "Test"

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let modelURL = Bundle.main.url(forResource: "SensorsDataModel", withExtension: "momd") else { return nil }
        return NSManagedObjectModel(contentsOf: modelURL)
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let managedObjectModel =  self.managedObjectModel else { return nil }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
     
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
         
        return coordinator
    }()
    
    
    
    let locationManager = CLLocationManager()
    let motion = CMMotionManager()
    var timer = Timer()
    var tempString = ""
    
    var locationData = ""
    var accelerometerData = ""
    var gyroData = ""
    var magnetoneterData = ""
    
    var prevDate: Date?
    

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        startLocation()
        startAccelerometers()
        startMagnetometer()
        startGyros()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func startLocation() {
        locationManager.delegate = self
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func startAccelerometers() {
        // Make sure the accelerometer hardware is available.
        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = 1  // 1.0 / 60.0 = 60 Hz
            self.motion.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
                self.writeAccelerometerData()
            }
        }
    }
    
    func startGyros() {
        if motion.isGyroAvailable {
            self.motion.gyroUpdateInterval = 1
            self.motion.startGyroUpdates(to: OperationQueue.main) { (data, error) in
                self.writeGyroData()
            }
        }
    }
    
    func startMagnetometer () {
        if motion.isMagnetometerAvailable {
            motion.magnetometerUpdateInterval = 1
            motion.startMagnetometerUpdates(to: OperationQueue.main) { (data, error) in
                self.writeMagnetometerData()
            }
        }
    }
    
    func stopSensors() {
        self.timer.invalidate()
        self.motion.stopGyroUpdates()
        self.motion.stopAccelerometerUpdates()
        self.motion.stopMagnetometerUpdates()
        self.locationManager.stopUpdatingLocation()
    }
    
    func writeGyroData() {
        // Get the gyro data.
        if let data = self.motion.gyroData {
            let x = data.rotationRate.x
            let y = data.rotationRate.y
            let z = data.rotationRate.z
            self.gyroData = "Gyroscope: x:\(x), y:\(y), z:\(z)"
        }
    }
    
    func writeAccelerometerData() {
        // Get the acceleration data.
        if let data = self.motion.accelerometerData {
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            self.accelerometerData = "Acceleration: x:\(x), y:\(y), z:\(z)"
        }
    }
    
    func writeMagnetometerData() {
        // Get the magnetometer data.
        if let data = self.motion.magnetometerData {
            let x = data.magneticField.x
            let y = data.magneticField.y
            let z = data.magneticField.z
            self.magnetoneterData = "Magnetometer: x:\(x), y:\(y), z:\(z)"
        }
    }
    
    
    
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("Access to location granted")
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            addToFile(string: "Location is \(location)")
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location error", error.localizedDescription)
    }
}

extension AppDelegate {
    func addToFile(string: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
        
        let motionSensorDate = "\n\(gyroData), \n\(magnetoneterData), \n\(accelerometerData), \n\(string)\n\n"
        var data = dateFormatter.string(from: Date()) + motionSensorDate
        if let previousData = self.readDataFromFile() {
            data = data + previousData
        }
        self.writeDataToFile(data: data)
        
    }
    
    func writeDataToFile(data: String) -> Bool {
        do {
            let documentDirURL = try FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
            try data.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            return true
        } catch (let error) {
            print(error.localizedDescription)
        }
        return false
    }
    
    func readDataFromFile() -> String? {
        do {
            let documentDirURL = try FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
            return try String(contentsOf: fileURL)
        } catch (let error) {
            print(error.localizedDescription)
        }
        return nil
    }
}

