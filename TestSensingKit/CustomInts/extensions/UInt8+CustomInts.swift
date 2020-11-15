//
//  UInt8+CustomInts.swift
//  CustomInts
//
//  Created by Kseniia Shkurenko on 09.11.2020.
//

import Foundation

internal extension UInt8 {
    /// Indicates if bit 8 is set
    var hasMinusBit: Bool { return ((self & 0x80) == 0x80) }
}
