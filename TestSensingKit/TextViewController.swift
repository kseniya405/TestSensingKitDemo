//
//  ViewController.swift
//  CoreLocationTest
//
//  Created by Ксения Шкуренко on 11.10.2020.
//

import UIKit
import ModelIO


struct SensorsEntities {
    let date: Date
    let type: EntityType
    var location: LocationSensorEntity? = nil
    var gyroscope: GyroscopeSensorEntity? = nil
    var magnetometer: MagnetometerSensorEntity? = nil
    var accelerometer: AccelerometerSensorEntity? = nil
    
}

enum EntityType {
    case location
    case gyroscope
    case magnetometer
    case accelerometer
}

class TextViewController: UIViewController {
    
    @IBOutlet weak var dataTextView: UITextView! {
        didSet {
            dataTextView.contentInset.bottom = 55
        }
    }
    @IBOutlet weak var stopUpdateButton: UIButton! {
        didSet {
            stopUpdateButton.addTarget(self, action: #selector(stopUpdateButtonDidTap), for: .touchUpInside)
            stopUpdateButton.setTitleColor(.gray, for: .normal)
        }
    }
    @IBOutlet weak var startUpdateButton: UIButton! {
        didSet {
            startUpdateButton.addTarget(self, action: #selector(startUpdateButtonDidTap), for: .touchUpInside)
            startUpdateButton.setTitleColor(.black, for: .normal)
        }
    }
    
    
    @IBAction func updateButtonDidTap(_ sender: Any) {
        dataTextView.text = readDataFromDatabase()
        
    }
    
    @IBAction func deleteButtonDidTap(_ sender: Any) {
        do {
            let documentDirURL = try FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirURL.appendingPathComponent("Test").appendingPathExtension("txt")
            try "".write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            dataTextView.text = readDataFromFile()
            try CoreDataManager.shared.deleteLocations()
            try CoreDataManager.shared.deleteGyro()
            try CoreDataManager.shared.deleteAccelerometer()
            try CoreDataManager.shared.deleteMagnetometer()
        } catch (let error) {
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func exportButtonDidTap(_ sender: Any) {
        
        let text = readDataFromDatabase()
        let textData = text.data(using: .utf8)
        
        guard let textURL = textData?.dataToFile(fileName: "sensors_data_list.txt") else {return }
        
        var filesToShare = [Any]()
        
        filesToShare.append(textURL)
        
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    var entities = [SensorsEntities]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataTextView.text = readDataFromDatabase()
        //        setSensorMask()
        
        writeToDataFile()
    }
    
    @objc func stopUpdateButtonDidTap() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.stopSensors()
        startUpdateButton.setTitleColor(.black, for: .normal)
        stopUpdateButton.setTitleColor(.gray, for: .normal)
        
    }
    
    @objc func startUpdateButtonDidTap() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.startSensors()
        startUpdateButton.setTitleColor(.gray, for: .normal)
        stopUpdateButton.setTitleColor(.black, for: .normal)
    }
    
    func readDataFromFile() -> String? {
        do {
            let documentDirURL = try FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentDirURL.appendingPathComponent("Test").appendingPathExtension("txt")
            return try String(contentsOf: fileURL)
        } catch (let error) {
            print(error.localizedDescription)
        }
        return nil
    }
    
    fileprivate func readDataFromDatabase() -> String {
        
        var sensorsDataList = ""
        do {
            if let lastLocation = try CoreDataManager.shared.getLastLocation() {
                if let previousDate = SensorData.shared.lastUpdateData, let lastExportedLocation = try CoreDataManager.shared.getLastLocationBeforeDate(date: previousDate)  {
                    let locationDeltaLatitude = lastLocation.latitude - lastExportedLocation.latitude
                    let locationDeltaLongtitude = lastLocation.longtitude - lastExportedLocation.longtitude
                    let locationDeltaAltitude = lastLocation.altitude - lastExportedLocation.altitude
                    sensorsDataList.append("Location delta: latitude:\(locationDeltaLatitude), longtitude:\(locationDeltaLongtitude), altitude:\(locationDeltaAltitude) from \(stringFromDate(date: lastLocation.date ?? Date()))\n")
                } else {
                    sensorsDataList.append("Location initial: latitude:\(lastLocation.latitude), longtitude:\(lastLocation.longtitude), altitude:\(lastLocation.accuracy) from \(stringFromDate(date: lastLocation.date ?? Date()))\n")
                }
            }
            if let lastGyroscope = try CoreDataManager.shared.getLastGyroscope() {
                sensorsDataList.append("Gyroscope : x:\(lastGyroscope.x), y:\(lastGyroscope.y), z:\(lastGyroscope.z) from \(stringFromDate(date: lastGyroscope.date ?? Date()))\n")
            }
            //            let gyros = try CoreDataManager.shared.fetchGyroscope().map({ (item) -> SensorsEntities in
            //                let date = item.date ?? Date(timeIntervalSince1970: 0)
            //                return SensorsEntities(date: date, type: .gyroscope, gyroscope: item)
            //            })
            //            let accelerometers = try CoreDataManager.shared.fetchAccelerometer().map({ (item) -> SensorsEntities in
            //                let date = item.date ?? Date(timeIntervalSince1970: 0)
            //                return SensorsEntities(date: date, type: .accelerometer, accelerometer: item)
            //            })
            //            let magnetometers = try CoreDataManager.shared.fetchMagnetometer().map({ (item) -> SensorsEntities in
            //                let date = item.date ?? Date(timeIntervalSince1970: 0)
            //                return SensorsEntities(date: date, type: .magnetometer, magnetometer: item)
            //            })
            //            var allSensors = gyros + accelerometers + magnetometers
            //            allSensors.sort(by: {$0.date > $1.date})
            //
            //
            //
            //            allSensors.forEach { (item) in
            //                switch item.type {
            //
            //                case .location:
            //                    if let location = item.location {
            //                        let latitude = location.latitude
            //                        let longtitude = location.longtitude
            //                        let altitude = location.altitude
            //
            //                        sensorsDataList.append("Location: x:\(latitude), y:\(longtitude), z:\(altitude) from \(stringFromDate(date: item.date))\n")
            //                    }
            //                case .gyroscope:
            //                    if let gyroscope = item.gyroscope {
            //                        let x = gyroscope.x
            //                        let y = gyroscope.y
            //                        let z = gyroscope.z
            //
            //                        sensorsDataList.append("Gyroscope: x:\(x), y:\(y), z:\(z) from \(stringFromDate(date: item.date))\n")
            //                    }
            //                case .magnetometer:
            //                    if let magnetometer = item.magnetometer {
            //                        let x = magnetometer.x
            //                        let y = magnetometer.y
            //                        let z = magnetometer.z
            //
            //                        sensorsDataList.append("Magnetometer: x:\(x), y:\(y), z:\(z) from \(stringFromDate(date: item.date))\n")
            //                    }
            //                case .accelerometer:
            //                    if let accelerometer = item.accelerometer {
            //                        let x = accelerometer.x
            //                        let y = accelerometer.y
            //                        let z = accelerometer.z
            //
            //                        sensorsDataList.append("Acceleration: x:\(x), y:\(y), z:\(z) from \(stringFromDate(date: item.date))\n")
            //                    }
            //                }
            //            }
            
            SensorData.shared.lastUpdateData = Date()
            return sensorsDataList
        }
        catch {
            print("Can't read data from CoreData")
            return ""
        }
        
    }
    
    func stringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
        return dateFormatter.string(from: date)
    }
    
    
    struct SensorsMask: OptionSet {
        
        let rawValue: UInt
        
        static let pressure = SensorsMask(rawValue: 1 << 0)
        static let gyro = SensorsMask(rawValue: 1 << 1)
        static let magnetometer = SensorsMask(rawValue: 1 << 2)
        static let accelerometer = SensorsMask(rawValue: 1 << 3)
        static let temperature = SensorsMask(rawValue: 1 << 4)
        static let light = SensorsMask(rawValue: 1 << 5)
        static let locationWiFi = SensorsMask(rawValue: 1 << 6)
        static let locationGPS = SensorsMask(rawValue: 1 << 7)
    }
    
    func setSensorMask() -> SensorsMask {
        var mask: SensorsMask = []
        mask.insert(.accelerometer)
        mask.insert(.gyro)
        mask.insert(.magnetometer)
        mask.insert(.locationGPS)
        return mask
    }
    
    func getHeader() {
        // let formatVersion =
    }
    
    func writeToDataFile() {
        
        do {
            
            let filemgr = FileManager.default
            guard let path = filemgr.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last?.appendingPathComponent("out.neolog") else { return }
            
            var sensorData = Data()
            
            let location = try CoreDataManager.shared.getLastLocation()
            if let latidude = location?.latitude,
               let longtitude = location?.longtitude,
               let altidude = location?.altitude,
               let accuracy = location?.accuracy {
                
                print(latidude, "latitude on write \n", longtitude, "longtitude on write \n", altidude, "altidude on write")
                
                var latitudeValue = Int32(latidude * 1000000).bigEndian
                let latitudeData = withUnsafePointer(to: &latitudeValue) { Data(buffer: UnsafeBufferPointer(start: $0, count: 1))}
                sensorData.append(latitudeData)
                                
                var longtitudeValue = Int32(longtitude * 1000000).bigEndian
                let longtitudeData = withUnsafePointer(to: &longtitudeValue) { Data(buffer: UnsafeBufferPointer(start: $0, count: 1))}
                sensorData.append(longtitudeData)
                
                var altidudeValue = UInt24(altidude * 10).bigEndian
                let altidudeData = withUnsafePointer(to: &altidudeValue) { Data(buffer: UnsafeBufferPointer(start: $0, count: 1))}
                sensorData.append(altidudeData)
                
                var accuracyValue = accuracy.bitPattern.bigEndian
                let accuracyData = withUnsafePointer(to: &accuracyValue) { Data(buffer: UnsafeBufferPointer(start: $0, count: 1))}
                sensorData.append(accuracyData)
            }

            let gyroscope = try CoreDataManager.shared.getLastGyroscope()
            if let gyroscopeX = gyroscope?.x.bitPattern.bigEndian,
               let gyroscopeY = gyroscope?.y.bitPattern.bigEndian,
               let gyroscopeZ = gyroscope?.z.bitPattern.bigEndian {
                
                print(gyroscopeX, "gyroscopeX on write")
                               print(gyroscopeY, "gyroscopeY on write")
                               print(gyroscopeZ, "gyroscopeZ on write")
                sensorData.append(withUnsafeBytes(of: gyroscopeX) { Data($0) })
                sensorData.append(withUnsafeBytes(of: gyroscopeY) { Data($0) })
                sensorData.append(withUnsafeBytes(of: gyroscopeZ) { Data($0) })

            }

            let magnetometer = try CoreDataManager.shared.getLastMagnetometer()
            if let magnetometerX = magnetometer?.x.bitPattern.bigEndian,
               let magnetometerY = magnetometer?.y.bitPattern.bigEndian,
               let magnetometerZ = magnetometer?.z.bitPattern.bigEndian {
                print(magnetometerX, "magnetometerX on write")
                               print(magnetometerY, "magnetometerY on write")
                               print(magnetometerZ, "magnetometerZ on write")
                sensorData.append(withUnsafeBytes(of: magnetometerX) { Data($0) })
                sensorData.append(withUnsafeBytes(of: magnetometerY) { Data($0) })
                sensorData.append(withUnsafeBytes(of: magnetometerZ) { Data($0) })

            }

            let accelerometer = try CoreDataManager.shared.getLastAccelerometer()
            if let accelerometerX = accelerometer?.x.bitPattern.bigEndian,
               let accelerometerY = accelerometer?.y.bitPattern.bigEndian,
               let accelerometerZ = accelerometer?.z.bitPattern.bigEndian {
                print(accelerometerX, "accelerometerX on write")
                               print(accelerometerY, "accelerometerY on write")
                               print(accelerometerZ, "accelerometerZ on write")
                sensorData.append(withUnsafeBytes(of: accelerometerX) { Data($0) })
                sensorData.append(withUnsafeBytes(of: accelerometerY) { Data($0) })
                sensorData.append(withUnsafeBytes(of: accelerometerZ) { Data($0) })

            }
            
            try sensorData.write(to: path, options: .atomicWrite)
            
            let data =  try Data(contentsOf: path, options: .uncachedRead)
            readData(data: data)
            print(data, "data from file")
            
        }
        catch {
            print("Something went wrong")
        }
        
    }
    
    func readData(data: Data) {
        do {
        if data.count > 0 {
            let binary = BinaryData(data: data, bigEndian: true)
            let latitude: Int32 = try binary.get(0)
            let longtitude: Int32 = try binary.get(4)
            let altidude: UInt24 = try binary.get(8)
            
            // Float32, Int32 == 4 байта, тоесть если считываем флоат32 методом get(0), то следующий показатель = get(4)
            print(latitude, longtitude, altidude, "latitude on read")
        }
        } catch let error {
            print(error)
        }
    }
    
}


