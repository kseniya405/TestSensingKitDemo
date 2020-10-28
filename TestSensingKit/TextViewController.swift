//
//  ViewController.swift
//  CoreLocationTest
//
//  Created by Ксения Шкуренко on 11.10.2020.
//

import UIKit

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
        do {
            let locations = try CoreDataManager.shared.fetchLocations().map({ (item) -> SensorsEntities in
                let date = item.date ?? Date(timeIntervalSince1970: 0)
                return SensorsEntities(date: date, type: .location, location: item)
            })
            let gyros = try CoreDataManager.shared.fetchGyro().map({ (item) -> SensorsEntities in
                let date = item.date ?? Date(timeIntervalSince1970: 0)
                return SensorsEntities(date: date, type: .gyroscope, gyroscope: item)
            })
            let accelerometers = try CoreDataManager.shared.fetchAccelerometer().map({ (item) -> SensorsEntities in
                let date = item.date ?? Date(timeIntervalSince1970: 0)
                return SensorsEntities(date: date, type: .accelerometer, accelerometer: item)
            })
            let magnetometers = try CoreDataManager.shared.fetchMagnetometer().map({ (item) -> SensorsEntities in
                let date = item.date ?? Date(timeIntervalSince1970: 0)
                return SensorsEntities(date: date, type: .magnetometer, magnetometer: item)
            })
            var allSensors = locations + gyros + accelerometers + magnetometers
            allSensors.sort(by: {$0.date > $1.date})
            
            var sensorsDataList = ""
            
            allSensors.forEach { (item) in
                switch item.type {
                
                case .location:
                    if let location = item.location {
                        let latitude = location.latitude
                        let longtitude = location.longtitude
                        let altitude = location.altitude
                        
                        sensorsDataList.append("Location: x:\(latitude), y:\(longtitude), z:\(altitude) from \(stringFromDate(date: item.date))\n")
                    }
                case .gyroscope:
                    if let gyroscope = item.gyroscope {
                        let x = gyroscope.x
                        let y = gyroscope.y
                        let z = gyroscope.z
                        
                        sensorsDataList.append("Gyroscope: x:\(x), y:\(y), z:\(z) from \(stringFromDate(date: item.date))\n")
                    }
                case .magnetometer:
                    if let magnetometer = item.magnetometer {
                        let x = magnetometer.x
                        let y = magnetometer.y
                        let z = magnetometer.z
                        
                        sensorsDataList.append("Magnetometer: x:\(x), y:\(y), z:\(z) from \(stringFromDate(date: item.date))\n")
                    }
                case .accelerometer:
                    if let accelerometer = item.accelerometer {
                        let x = accelerometer.x
                        let y = accelerometer.y
                        let z = accelerometer.z
                        
                        sensorsDataList.append("Acceleration: x:\(x), y:\(y), z:\(z) from \(stringFromDate(date: item.date))\n")
                    }
                }
            }
            
            
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
    

}

