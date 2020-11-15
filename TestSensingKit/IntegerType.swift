//
//  IntegerType.swift
//  BinaryData
//
//  Created by Kseniia Shkurenko on 09.11.2020.
//

import Foundation

extension UInt16 {
  static func join(_ parts: (UInt8, UInt8), bigEndian: Bool) -> UInt16 {
    let tuple = toUInt16(applyOrder(parts, bigEndian))
    return (UInt16(tuple.1) << 8) | UInt16(tuple.0)
    
  }
}

extension UInt24 {
  static func join(_ parts: (UInt8, UInt8, UInt8), bigEndian: Bool) -> UInt24 {
    let tuple = toUInt24(applyOrder(parts, bigEndian))
    let tuple16 = UInt24(tuple.2) << 16
    let tuple8 = UInt24(tuple.1) << 8
    let tuple0 = UInt24(tuple.0)
    return tuple16 | tuple8 | tuple0
    
  }
}

extension UInt32 {
  static func join(_ parts:(UInt8, UInt8, UInt8, UInt8), bigEndian: Bool) -> UInt32 {
    let tuple = toUInt32(applyOrder(parts, bigEndian))
    let tuple24 = UInt32(tuple.3) << 24
    let tuple16 = UInt32(tuple.2) << 16
    let tuple8 = UInt32(tuple.1) << 8
    let tuple0 = UInt32(tuple.0)
    return tuple24 | tuple16 | tuple8 | tuple0
  }
}

extension UInt64 {
  static func join(_ parts:(UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8), bigEndian: Bool) -> UInt64{
    let tuple = toUInt64(applyOrder(parts, bigEndian))
    return (tuple.7 << 56) | (tuple.6 << 48) | (tuple.5 << 40) | (tuple.4 << 32)
      | (tuple.3 << 24) | (tuple.2 << 16) | (tuple.1 << 8) | tuple.0
  }
}
