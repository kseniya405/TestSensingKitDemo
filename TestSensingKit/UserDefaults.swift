//
//  UserDefaults.swift
//  TestSensingKit
//
//  Created by Ксения Шкуренко on 04.10.2020.
//

import Foundation

class SensorData {
    static let shared = SensorData()
    
    var backgroundAverageFrequencyLocationList: [Double]  {
        get {
            return UserDefaults.standard.array(forKey: #function) as? [Double] ?? []
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    var backgroundAverageFrequencyLocation: Double {
        get {
            return UserDefaults.standard.double(forKey: #function)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
    
    var lastUpdateData: Date? {
        get {
            return UserDefaults.standard.object(forKey: #function) as? Date
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }
}
