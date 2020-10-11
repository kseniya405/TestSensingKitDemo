//
//  ViewController.swift
//  TestSensingKit
//
//  Created by Ксения Шкуренко on 01.10.2020.
//

import UIKit
import SensingKit
import SensorKit
import Pods_TestSensingKit

fileprivate let fileName = "Test"

let sensingKit = SensingKitLib.shared()
var allSensorType = [sensorData]()

struct sensorData {
    let type: SKSensorType
    var data: String
    var prevDate: Date
    var frequency: [TimeInterval]
    var averageFrequency: TimeInterval = 0
    var backgroundFrequency: [TimeInterval] = []
    var backgroundAverageFrequency: TimeInterval = 0
    
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var documentDirURL: URL?
    
    var fileURL: URL?
    
    struct sensorData {
        let type: SKSensorType
        var data: String
        var prevDate: Date
        var frequency: [TimeInterval]
        var averageFrequency: TimeInterval = 0.0
        var backgroundFrequency: [TimeInterval] = SensorData.shared.backgroundAverageFrequencyLocationList
        var backgroundAverageFrequency: TimeInterval = SensorData.shared.backgroundAverageFrequencyLocation
    }
    
    let sensorDataTableViewCell = "SensorDataTableViewCell"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        configurateTableView()
//        
//        SensorData.shared.backgroundAverageFrequencyLocationList = []
//        SensorData.shared.backgroundAverageFrequencyLocation = 0.0
//        
//        print("File Text: \(readDataFromFile() ?? "text file is empty")")
//        configurateSensors()
//        
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
//            var data = dateFormatter.string(from: Date()) //+ String(describing: self.allSensorType)
//            if let previousData = self.readDataFromFile() {
//                data = previousData + data
//            }
//            self.writeDataToFile(data: data)
//            let offset = self.tableView.contentOffset
//            self.tableView.reloadData()
//            self.tableView.setContentOffset(offset, animated: false)
//            self.tableView.layoutIfNeeded()
//            self.tableView.updateConstraintsIfNeeded()
//        }
        
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
    
    func configurateTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: sensorDataTableViewCell, bundle: nil), forCellReuseIdentifier: sensorDataTableViewCell)
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
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
                    _ = self.writeDataToFile(data: dateFormatter.string(from: Date()))

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


extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allSensorType.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: sensorDataTableViewCell, for: indexPath) as! SensorDataTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.set(sensorName: "Sensor", sensorData: "Data", updateFrequency: "Update frequency")
        default:
            if indexPath.row - 1 < allSensorType.count {
                cell.set(sensorName: getSensorName(type: allSensorType[indexPath.row - 1].type), sensorData: allSensorType[indexPath.row - 1].data, updateFrequency: "all: \(allSensorType[indexPath.row - 1].averageFrequency), background: \(allSensorType[indexPath.row - 1].backgroundAverageFrequency)")
            }
        }
        
        return cell
    }
    
    
}

extension Sequence where Element: AdditiveArithmetic {
    /// Returns the total sum of all elements in the sequence
    func sum() -> Element { reduce(.zero, +) }
}

extension Collection where Element: BinaryFloatingPoint {
    /// Returns the average of all elements in the array
    func average() -> Element { isEmpty ? .zero : Element(sum()) / Element(count) }
}
