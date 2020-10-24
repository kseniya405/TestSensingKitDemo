//
//  ViewController.swift
//  CoreLocationTest
//
//  Created by Ксения Шкуренко on 11.10.2020.
//

import UIKit

class TextViewController: UIViewController {

    @IBOutlet weak var dataTextView: UITextView!
    
    @IBAction func updateButtonDidTap(_ sender: Any) {
        dataTextView.text = readDataFromFile()
        do {
            let locations = try CoreDataManager.shared.fetchLocations()
            for loc in locations {
                print(loc.date, "locations from CoreData")
            }
            
            let latestLoc = try CoreDataManager.shared.getLastLocation().first
            print(latestLoc?.date, "latest locations from CoreData")
        }
        catch {
            print("Can't read data from CoreData")
        }
        do {
            let gyros = try CoreDataManager.shared.fetchGyro()
            for gyro in gyros {
                print(gyro.date, "gyro from CoreData")
            }
        }
        catch {
            print("Can't read data from CoreData")
        }
        do {
            let accelerometers = try CoreDataManager.shared.fetchAccelerometer()
            for accelerometer in accelerometers {
                print(accelerometer.date, "Accelerometer from CoreData")
            }
        }
        catch {
            print("Can't read data from CoreData")
        }
        do {
            let magnetometers = try CoreDataManager.shared.fetchMagnetometer()
            for magnetometer in magnetometers {
                print(magnetometer.date, "Magnetometer from CoreData")
            }
        }
        catch {
            print("Can't read data from CoreData")
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataTextView.text = readDataFromFile()
        
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
    

}

