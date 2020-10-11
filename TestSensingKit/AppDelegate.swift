//
//  AppDelegate.swift
//  TestSensingKit
//
//  Created by Ксения Шкуренко on 01.10.2020.
//

import UIKit
import SensingKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let fileName = "Test"

    var allSensorType = [sensorData(type: SKSensorType.Accelerometer, data: "", prevDate: Date(), frequency: []),
                         sensorData(type: SKSensorType.Gyroscope, data: "", prevDate: Date(), frequency: []),
                         sensorData(type: SKSensorType.Magnetometer, data: "", prevDate: Date(), frequency: []),
                         sensorData(type: SKSensorType.DeviceMotion, data: "", prevDate: Date(), frequency: []),
                         sensorData(type: SKSensorType.MotionActivity, data: "", prevDate: Date(), frequency: []),
                         sensorData(type: SKSensorType.Pedometer, data: "", prevDate: Date(), frequency: []),
                         sensorData(type: SKSensorType.Altimeter, data: "", prevDate: Date(), frequency: []),
                         sensorData(type: SKSensorType.Battery, data: "", prevDate: Date(), frequency: []),
                         sensorData(type: SKSensorType.Location, data: "", prevDate: Date(), frequency: []),
                         sensorData(type: SKSensorType.Heading, data: "", prevDate: Date(), frequency: []),
                         sensorData(type: SKSensorType.iBeaconProximity, data: "", prevDate: Date(), frequency: []),
                         sensorData(type: SKSensorType.EddystoneProximity, data: "", prevDate: Date(), frequency: []),
                         sensorData(type: SKSensorType.Microphone, data: "", prevDate: Date(), frequency: [])]

    
    fileprivate func configurateSensors() {
        for sensor in allSensorType {
            do {
                try sensingKit.register(sensor.type)
                if sensor.type == .Location {
                    let conf = SKLocationConfiguration()
                    conf.locationAuthorization = .always
                    try sensingKit.setConfiguration(conf, to: .Location)
                }
                
                
            }
            catch {
                print(error.localizedDescription)
            }
            subscribeSensor(type: sensor.type, typeName: getSensorName(type: sensor.type))
            //             Start
            do {
                try sensingKit.startContinuousSensing(with: sensor.type)
            }
            catch(let error) {
                print(error.localizedDescription)
            }
            
            
            
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("File Text: \(readDataFromFile() ?? "text file is empty")")
        configurateSensors()
        
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
            var data = dateFormatter.string(from: Date()) //+ String(describing: self.allSensorType)
            if let previousData = self.readDataFromFile() {
                data = previousData + data
            }
            print(data)
            self.writeDataToFile(data: data)

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
    


func writeDataToFile(data: String) -> Bool {
    do {
        let documentDirURL = try FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        try data.write(to: fileURL, atomically: false, encoding: String.Encoding.utf8)
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
        let data = try String(contentsOf: fileURL)
        return data
    } catch (let error) {
        print(error.localizedDescription)
    }
    return nil
}


func subscribeSensor(type:SKSensorType, typeName: String) {
    print(self.getSensorIndex(type: type), self.getSensorName(type: type), "sensor index and name")
    do {
        try sensingKit.subscribe(to: type, withHandler: { (sensorType, sensorData, error) in
            
            if (error == nil) {
                
                let index = self.getSensorIndex(type: type)
                switch type {
                
                case .Accelerometer:
                    let data = sensorData as! SKAccelerometerData
                    self.allSensorType[index].data = "X: \(data.acceleration.x), Y: \(data.acceleration.y), Z: \(data.acceleration.z)"
                case .Gyroscope:
                    let data = sensorData as! SKGyroscopeData
                    self.allSensorType[index].data = "X: \(data.rotationRate.x), Y: \(data.rotationRate.y), Z: \(data.rotationRate.z)"
                case .Magnetometer:
                    let data = sensorData as! SKMagnetometerData
                    self.allSensorType[index].data = "X: \(data.magneticField.x), Y: \(data.magneticField.y), Z: \(data.magneticField.z)"
                case .DeviceMotion:
                    let data = sensorData as! SKDeviceMotionData
                    self.allSensorType[index].data = "Magnetic field: x:\(data.magneticField.field.x), y: \(data.magneticField.field.y), z: \(data.magneticField.field.z), attitude: \(data.attitude), rotationRate: \(data.rotationRate), userAcceleration : \(data.userAcceleration), gravity: \(data.gravity)"
                case .MotionActivity:
                    let data = sensorData as! SKMotionActivityData
                    self.allSensorType[index].data = "startDate: \(data.startDate), motion activity: \(data.motionActivity)"
                case .Pedometer:
                    let data = sensorData as! SKPedometerData
                    self.allSensorType[index].data = "startDate: \(data.startDate), number of steps: \(data.pedometerData.numberOfSteps), endDate: \(data.endDate)"
                case .Altimeter:
                    let data = sensorData as! SKAltimeterData
                    self.allSensorType[index].data = "pressure: \(data.altitudeData.pressure),  relative altitude: \(data.altitudeData.relativeAltitude)"
                case .Battery:
                    let data = sensorData as! SKBatteryData
                    self.allSensorType[index].data = "level: \(data.level), state: \(data.state)"
                case .Location:
                    let data = sensorData as! SKLocationData
                    self.allSensorType[index].data = "location: \(data.location)"
                case .Heading:
                    let data = sensorData as! SKHeadingData
                    self.allSensorType[index].data = "heading: \(data.heading)"
                case .iBeaconProximity:
                    let data = sensorData as! SKiBeaconDeviceData
                    self.allSensorType[index].data = "accuracy: \(data.accuracy), major: \(data.major), minor: \(data.minor), rssi: \(data.rssi), proximity: \(data.proximityString)"
                case .EddystoneProximity:
                    let data = sensorData as! SKEddystoneProximityData
                    self.allSensorType[index].data = "instance: \(data.instanceId),  rssi: \(data.rssi),  tx power: \(data.txPower)"
                case .Microphone:
                    let data = sensorData as! SKMicrophoneData
                    self.allSensorType[index].data = "state: \(data.state)"
                @unknown default:
                    print(index, self.getSensorName(type: sensorType), "sensor index and name")
                }
                
                
                if index == -1 { return }
                
                
                if UIApplication.shared.applicationState == .background {
                    self.allSensorType[index].backgroundFrequency.append(Date().timeIntervalSince(self.allSensorType[index].prevDate))
                    self.allSensorType[index].backgroundAverageFrequency = self.allSensorType[index].backgroundFrequency.average()
                    if self.allSensorType[index].type == .Location {
                        SensorData.shared.backgroundAverageFrequencyLocationList = self.allSensorType[index].backgroundFrequency
                        SensorData.shared.backgroundAverageFrequencyLocation = self.allSensorType[index].backgroundAverageFrequency
                    }
                } else {
                    self.allSensorType[index].frequency.append(Date().timeIntervalSince(self.allSensorType[index].prevDate))
                    self.allSensorType[index].averageFrequency = self.allSensorType[index].frequency.average()
                }
                self.allSensorType[index].prevDate = Date()

                self.writeDataToFile(data: Date().description)
                self.readDataFromFile()
            }
        })
    }
    catch {
        print(error.localizedDescription)
    }
}

//    func updateSensorData(data: SKSensorData, ) {
//
//    }

func getSensorName(type: SKSensorType) -> String {
    switch type {
    case .Accelerometer:
        return "Accelerometer"
    case .Gyroscope:
        return "Gyroscope"
    case .Magnetometer:
        return "Magnetometer"
    case .DeviceMotion:
        return "DeviceMotion"
    case .MotionActivity:
        return "MotionActivity"
    case .Pedometer:
        return "Pedometer"
    case .Altimeter:
        return "Altimeter"
    case .Battery:
        return "Battery"
    case .Location:
        return "Location"
    case .Heading:
        return "Heading"
    case .iBeaconProximity:
        return "iBeaconProximity"
    case .EddystoneProximity:
        return "EddystoneProximity"
    case .Microphone:
        return "Microphone"
    @unknown default:
        return "unknown default"
    }
}

func getSensorIndex(type: SKSensorType) -> Int {
    switch type {
    case .Accelerometer:
        return 0
    case .Gyroscope:
        return 1
    case .Magnetometer:
        return 2
    case .DeviceMotion:
        return 3
    case .MotionActivity:
        return 4
    case .Pedometer:
        return 5
    case .Altimeter:
        return 6
    case .Battery:
        return 7
    case .Location:
        return 8
    case .Heading:
        return 9
    case .iBeaconProximity:
        return 10
    case .EddystoneProximity:
        return 11
    case .Microphone:
        return 12
    @unknown default:
        return -1
    }
}
}
