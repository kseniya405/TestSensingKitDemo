//
//  Bundle+VersionNumber.swift
//  TestSensingKit
//
//  Created by Kseniia Shkurenko on 31.10.2020.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
