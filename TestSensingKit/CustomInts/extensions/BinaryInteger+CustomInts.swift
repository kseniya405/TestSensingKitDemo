//
//  BinaryInteger+CustomInts.swift
//  CustomInts
//
//  Created by Kseniia Shkurenko on 09.11.2020.
//
import Foundation


public extension BinaryInteger {
    // Allows for an optional initializer that takes an optional BinaryInteger.
    // This is usefull when needing to cast one optional integer type to another optional integer type
    init?<T>(_ source: T?) where T : BinaryInteger {
        guard let s = source else { return nil }
        self.init(s)
    }
}

internal extension BinaryInteger {
    
    /// Provides an unsafe UInt8 buffer pointer for use
    func useUnsafeBufferPointer<T>(_ function: @escaping (UnsafeBufferPointer<UInt8>) -> T) -> T {
        var mutableSource = self
        let size = MemoryLayout.size(ofValue: mutableSource)
        let rtn: T =  withUnsafePointer(to: &mutableSource) {
            return $0.withMemoryRebound(to: UInt8.self, capacity: size) {
                let buffer = UnsafeBufferPointer(start: $0, count: size)
                return function(buffer)
            }
        }
        return rtn
    }
    /// Compares all bytes within integer to make sure they are all zero
    var isZero: Bool {
        return useUnsafeBufferPointer {
            return !$0.contains(where: { $0 != 0x00 })
        }
    }
    
    /// returns the most significant byte of the integers.  for big endian systems this is byte[0].  For little endian systems this is byte[byte.count - 1]
    var mostSignificantByte: UInt8 {
        return useUnsafeBufferPointer {
            if IntLogic.IS_BIGENDIAN { return UInt8($0.first!) }
            else { return UInt8($0.last!) }
        }
    }
    
    /// Indicates if this number is a negative.  First checks number type for isSigned flag.  Then check the 8 bit on the most significant byte
    var isNegative: Bool {
        guard Self.isSigned else { return false }
        return self.mostSignificantByte.hasMinusBit
    }
    
    /// Returns the raw bytes of the integer in their origional order
    var bytes: [UInt8] {
        return useUnsafeBufferPointer { return Array<UInt8>($0) }
    }
    
    /// Returns the raw bytes in big endian order.  Most significat byte is byte[0]
    var bigEndianBytes: [UInt8] {
        var rtn = self.bytes
        if !IntLogic.IS_BIGENDIAN { rtn.reverse() }
        return rtn
    }
}
