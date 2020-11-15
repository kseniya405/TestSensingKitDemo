//
//  ints.dswift
//  CustomInts
//
//  Created by Kseniia Shkurenko on 09.11.2020.
//

import Foundation
import NumericPatches







public struct UInt24: FixedWidthInteger, UnsignedInteger, CustomReflectable {
    
    /// A type that represents an integer literal.
    public typealias IntegerLiteralType = UInt32
    
    public struct Words: RandomAccessCollection {
        public typealias Index = Int
        public typealias Element = UInt
        //public typealias Indices = DefaultIndices<UInt24.Words>
        //public typealias SubSequence = Slice<UInt24.Words>
        
        internal var _value: UInt24
        
        public init(_ value: UInt24) {
            self._value = value
        }
        
        public let count: Int = 1
        
        public var startIndex: Int = 0
        
        public var endIndex: Int { return count }
        
        //public var indices: Indices { return startIndex ..< endIndex }
        
        @_transparent
        public func index(after i: Int) -> Int { return i + 1 }
        
        @_transparent
        public func index(before i: Int) -> Int { return i - 1 }
        
        public subscript(position: Int) -> UInt {
            guard position == startIndex else { fatalError("Index out of bounds") }
            
            var mutableSource = _value
            let size = MemoryLayout.size(ofValue: mutableSource)
            var bytes: [UInt8] =  withUnsafePointer(to: &mutableSource) {
                return $0.withMemoryRebound(to: UInt8.self, capacity: size) {
                    let buffer = UnsafeBufferPointer(start: $0, count: size)
                    return Array<UInt8>(buffer)
                    
                }
            }
            
            if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
            let isNeg = (UInt24.isSigned && bytes[0].hasMinusBit )
            bytes = IntLogic.paddBinaryInteger(bytes, newSizeInBytes: (UInt.bitWidth / 8), isNegative: isNeg)
            
            if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
            
            return bytes.withUnsafeBufferPointer {
                return $0.baseAddress!.withMemoryRebound(to: UInt.self, capacity: 1) {
                    return UInt($0.pointee)
                }
            }
        }
    }
    
    public static let isSigned: Bool = false
    public static let bitWidth: Int = 24
    
    public static let min: UInt24 = UInt24()
    public static let max: UInt24 = 16777215
    
    
    public static let zero: UInt24 = UInt24()
    internal static let one: UInt24 = 1
    
    
    /// Creates custom mirror to hide all details about ourselves
    public var customMirror: Mirror { return Mirror(self, children: EmptyCollection()) }
    
    public var words: UInt24.Words { return UInt24.Words(self) }
    
    /// Returns a count of all non zero bits in the number
    public var nonzeroBitCount: Int {
        return useUnsafeBufferPointer {
            var rtn: Int = 0
            for b in $0 {
                for i in (0..<8) {
                    let mask = UInt8(1 << i)
                    if ((b & mask) == mask) { rtn += 1}
                }
            }
            return rtn
        }
    }
    
    /// Returns a new instances of this number type with our byts reversed
    public var byteSwapped: UInt24 {
        
        return useUnsafeBufferPointer {
            var bytes = Array<UInt8>($0)
            bytes.reverse()
            return UInt24(bytes)
        }
        
    }
    
    /// Returns the number of leading zeros in this number.  If the number is negative this will return 0
    public var leadingZeroBitCount: Int {
        
        return useUnsafeBufferPointer {
            var range = Array<Int>(0..<$0.count)
            if !IntLogic.IS_BIGENDIAN { range = range.reversed() }
            var foundBit: Bool = false
            var rtn: Int = 0
            for i in range where !foundBit {
                for x in (0..<8).reversed() where !foundBit {
                    let mask = UInt8(1 << x)
                    foundBit = (($0[i] & mask) == mask)
                    if !foundBit { rtn += 1 }
                }
            }
            return rtn
        }
    }
    
    /// Returns the number of trailing zeros in this number
    public var trailingZeroBitCount: Int {
        return useUnsafeBufferPointer {
            var range = Array<Int>(0..<$0.count)
            if IntLogic.IS_BIGENDIAN { range = range.reversed() }
            var foundBit: Bool = false
            var rtn: Int = 0
            for i in range where !foundBit {
                for x in (0..<8).reversed() where !foundBit {
                    let mask = UInt8(1 << x)
                    foundBit = (($0[i] & mask) == mask)
                    if !foundBit { rtn += 1 }
                }
            }
            return rtn
        }
    }
    
    public var magnitude: UInt24 {
        
        return self
        
    }
    
    public var bigEndian: UInt24 {
        if IntLogic.IS_BIGENDIAN { return self }
        else { return self.byteSwapped }
    }
    
    public var littleEndian: UInt24 {
        if !IntLogic.IS_BIGENDIAN { return self }
        else { return self.byteSwapped }
    }
    
    internal var bytes: [UInt8] { return [a, b, c] }
    
    /// Internal property used in basic operations
    fileprivate var iValue: Int {
        /*guard !self.isZero else { return 0 }
         
         var bytes = self.bigEndian.bytes
         bytes = IntLogic.resizeBinaryInteger(bytes, newSizeInBytes: (Int.bitWidth / 8), isNegative: self.isNegative)
         
         if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
         
         let rtn: Int = bytes.withUnsafeBufferPointer {
         return $0.baseAddress!.withMemoryRebound(to: Int.self, capacity: 1) {
         return Int($0.pointee)
         }
         }
         
         return rtn*/
        return Int(self)
    }
    
    #if !swift(>=4.0.9)
    public var hashValue: Int { return self.iValue.hashValue }
    #endif
    
    private var a, b, c: UInt8
    
    public init() {
        
        self.a = 0
        
        self.b = 0
        
        self.c = 0
        
    }
    
    public init(_ other: UInt24) {
        
        self.a = other.a
        
        self.b = other.b
        
        self.c = other.c
        
    }
    
    fileprivate init(_ bytes: [UInt8]) {
        let intByteSize: Int = UInt24.bitWidth / 8
        precondition(bytes.count == intByteSize, "Byte size missmatch. Expected \(intByteSize), recieved \(bytes.count)")
        self.init()
        
        // Copy bytes into self
        withUnsafeMutablePointer(to: &self) {
            $0.withMemoryRebound(to: UInt8.self, capacity: intByteSize) {
                let buffer = UnsafeMutableBufferPointer(start: $0, count: intByteSize)
                
                for i in 0..<buffer.count {
                    buffer[i] = bytes[i]
                }
            }
        }
        
    }
    
    /// Creates a new instance with the same memory representation as the given
    /// value.
    ///
    /// This initializer does not perform any range or overflow checking. The
    /// resulting instance may not have the same numeric value as
    /// `bitPattern`---it is only guaranteed to use the same pattern of bits in
    /// its binary representation.
    ///
    /// - Parameter x: A value to use as the source of the new instance's binary
    ///   representation.
    public init(bitPattern other: Int24) {
        precondition(UInt24.bitWidth == Int24.bitWidth, "BitWidth of UInt24 and Int24 do not match")
        
        self.init(other.bytes)
    }
    
    public init(bigEndian value: UInt24) {
        var bytes = value.bytes
        if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
        self.init(bytes)
    }
    
    public init(littleEndian value: UInt24) {
        var bytes = value.bytes
        if IntLogic.IS_BIGENDIAN { bytes.reverse() }
        self.init(bytes)
    }
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
    
    public init(_truncatingBits truncatingBits: UInt) {
        let typeSize: Int = MemoryLayout<UInt24>.size
        var bytes: [UInt8] =  truncatingBits.bytes
        
        if !IntLogic.IS_BIGENDIAN { bytes = bytes.reversed() }
        while bytes.count > typeSize { bytes.remove(at: 0) }
        
        if !IntLogic.IS_BIGENDIAN { bytes = bytes.reversed() }
        
        self.init(bytes)
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        
        // Set required specific integer type information
        let isLocalTypeSigned = UInt24.isSigned
        let localBitWidth = UInt24.bitWidth
        let localByteWidth = (localBitWidth / 8)
        let intType = UInt24.self
        
        var mutableSource = source
        
        let size = MemoryLayout<T>.size
        var bytes: [UInt8] =  withUnsafePointer(to: &mutableSource) {
            return $0.withMemoryRebound(to: UInt8.self, capacity: size) {
                return Array(UnsafeBufferPointer(start: $0, count: size))
            }
        }
        
        if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
        let isNegative = (T.isSigned && bytes[0].hasMinusBit)
        
        if !isLocalTypeSigned && T.isSigned && isNegative {
            fatalError("\(source) is not representable as a '\(intType)' instance")
        } else if isLocalTypeSigned && !T.isSigned && isNegative && bytes.count >= localByteWidth {
            fatalError("Not enough bits to represent a signed value")
        }
        
        bytes = IntLogic.resizeBinaryInteger(bytes, newSizeInBytes: localByteWidth, isNegative: (isNegative && T.isSigned))
        
        guard bytes.count == localByteWidth else { fatalError("Not enough bits to represent a signed value") }
        
        if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
        
        self.init(bytes)
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        let int: Int = Int(source)
        self.init(int)
    }
    #if swift(>=4.2)
    //public func hash(into hasher: inout Hasher) {
    //    self.iValue.hash(into: &hasher)
    //}
    #endif
    
    public func signum() -> UInt24 {
        
        if self.isZero { return UInt24.zero }
        else { return UInt24.one }
        
        
    }
    
    fileprivate mutating func invert() {
        let intByteSize: Int = UInt24.bitWidth / 8
        var bytes = self.bytes
        bytes = IntLogic.twosComplement(bytes)
        withUnsafeMutablePointer(to: &self) {
            $0.withMemoryRebound(to: UInt8.self, capacity: intByteSize) {
                let buffer = UnsafeMutableBufferPointer(start: $0, count: intByteSize)
                
                for i in 0..<buffer.count {
                    buffer[i] = bytes[i]
                }
            }
        }
    }
    
    public func addingReportingOverflow(_ rhs: UInt24) -> (partialValue: UInt24, overflow: Bool) {
        /*guard !rhs.isZero else { return (partialValue: self, overflow: false)  }
         guard !self.isZero else { return (partialValue: rhs, overflow: false)  }
         
         let r = IntLogic.binaryAddition(self.bigEndian.bytes,
         rhs.bigEndian.bytes,
         isSigned: UInt24.isSigned)
         
         var bytes = r.partial
         
         if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
         
         let value: UInt24 = bytes.withUnsafeBufferPointer {
         return $0.baseAddress!.withMemoryRebound(to: UInt24.self, capacity: 1) {
         return UInt24($0.pointee)
         }
         }
         return (partialValue: value, overflow: r.overflow)*/
        
        guard !rhs.isZero else { return (partialValue: self, overflow: false) }
        guard !self.isZero else { return (partialValue: rhs, overflow: false) }
        
        let r = UInt32(self).addingReportingOverflow(UInt32(rhs))
        
        if r.overflow ||
            r.partialValue > UInt32(UInt24.max) ||
            r.partialValue < UInt32(UInt24.min) {
            // Overflows over the bounds of our int
            return (partialValue: UInt24(truncatingIfNeeded: r.partialValue), overflow: true)
        }
        
        return (partialValue: UInt24(r.partialValue), overflow: false)
        
    }
    
    public func subtractingReportingOverflow(_ rhs: UInt24) -> (partialValue: UInt24, overflow: Bool) {
        /*guard !rhs.isZero else { return (partialValue: self, overflow: false)  }
         
         let r = IntLogic.binarySubtraction(self.bigEndian.bytes,
         rhs.bigEndian.bytes,
         isSigned: UInt24.isSigned)
         
         var bytes = r.partial
         
         if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
         
         let value: UInt24 = bytes.withUnsafeBufferPointer {
         return $0.baseAddress!.withMemoryRebound(to: UInt24.self, capacity: 1) {
         return UInt24($0.pointee)
         }
         }
         return (partialValue: value, overflow: r.overflow)*/
        
        guard !rhs.isZero else { return (partialValue: self, overflow: false) }
        guard !(self.isZero && UInt24.isSigned) else { return (partialValue: rhs, overflow: false) }
        
        let r = UInt32(self).subtractingReportingOverflow(UInt32(rhs))
        
        if r.overflow ||
            r.partialValue > UInt32(UInt24.max) ||
            r.partialValue < UInt32(UInt24.min) {
            // Overflows over the bounds of our int
            return (partialValue: UInt24(truncatingIfNeeded: r.partialValue), overflow: true)
        }
        
        return (partialValue: UInt24(r.partialValue), overflow: false)
        
    }
    
    public func multipliedFullWidth(by other: UInt24) -> (high: UInt24, low: UInt24) {
        /*let r = IntLogic.binaryMultiplication(self.bigEndian.bytes,
         other.bigEndian.bytes,
         isSigned: UInt24.isSigned)
         
         let low = r.low.withUnsafeBufferPointer {
         return $0.baseAddress!.withMemoryRebound(to: UInt24.self, capacity: 1) {
         return UInt24(bigEndian: $0.pointee)
         }
         }
         
         let high = r.high.withUnsafeBufferPointer {
         return $0.baseAddress!.withMemoryRebound(to: UInt24.self, capacity: 1) {
         return UInt24(bigEndian: $0.pointee)
         }
         }
         
         return (high: high, low: low)*/
        
        
        let r = UInt32(self).multipliedFullWidth(by: UInt32(other))
        
        let val = r.low
        
        let high = val >> UInt24.bitWidth
        let low = val - (high << UInt24.bitWidth)
        
        return (high: UInt24(high), low: UInt24(low))
        
    }
    
    public func multipliedReportingOverflow(by rhs: UInt24) -> (partialValue: UInt24, overflow: Bool) {
        /*guard !self.isZero && !rhs.isZero else { return (partialValue: UInt24(), overflow: false)  }
         
         let r = self.multipliedFullWidth(by: rhs)
         let val = UInt24(truncatingIfNeeded: r.low)
         //let val = UInt24(bitPattern: r.low)
         var overflow: Bool = false
         if !self.isZero && !rhs.isZero && val.isZero { overflow = true }
         else if !UInt24.isSigned && r.high == 1 { overflow = true }
         else if UInt24.isSigned && !self.isNegative && !rhs.isNegative && val.isNegative {
         overflow = true
         } else {
         if xor(self.isNegative, rhs.isNegative) && !val.isNegative { overflow = true }
         }
         
         return (partialValue: val, overflow: overflow)*/
        
        guard !self.isZero && !rhs.isZero else { return (partialValue: UInt24.zero, overflow: false) }
        
        let r = UInt32(self).multipliedReportingOverflow(by: UInt32(rhs))
        
        if r.overflow ||
            r.partialValue > UInt32(UInt24.max) ||
            r.partialValue < UInt32(UInt24.min) {
            // Overflows over the bounds of our int
            return (partialValue: UInt24(truncatingIfNeeded: r.partialValue), overflow: true)
        }
        
        return (partialValue: UInt24(r.partialValue), overflow: false)
        
    }
    
    public func dividingFullWidth(_ dividend: (high: UInt24, low: Magnitude)) -> (quotient: UInt24, remainder: UInt24) {
        // We are cheating here.  Instead of using our own code.  we are casting as base Int type
        
        
        let divisor = (UInt(dividend.high.iValue) << UInt(UInt24.bitWidth)) + UInt(dividend.low)
        
        let r = UInt(self.iValue).quotientAndRemainder(dividingBy: divisor)
        return (quotient: UInt24(r.quotient), remainder: UInt24(r.remainder))
        
    }
    
    public func dividedReportingOverflow(by rhs: UInt24) -> (partialValue: UInt24, overflow: Bool) {
        /*// We are cheating here.  Instead of using our own code.  we are casting as base Int type
         guard !self.isZero else { return (partialValue: UInt24(), overflow: false)  }
         guard !rhs.isZero else { return (partialValue: self, overflow: true)   }
         
         
         let intValue: UInt = UInt(self.iValue) / UInt(rhs.iValue)
         let hasOverflow = (intValue > UInt24.max.iValue || intValue < UInt24.min.iValue)
         return (partialValue: UInt24(truncatingIfNeeded: intValue), overflow: hasOverflow)
         */
        
        guard !self.isZero else { return (partialValue: UInt24.zero, overflow: false)  }
        guard !rhs.isZero else { return (partialValue: self, overflow: true) }
        
        let r = UInt32(self).dividedReportingOverflow(by: UInt32(rhs))
        
        if r.overflow ||
            r.partialValue > UInt32(UInt24.max) ||
            r.partialValue < UInt32(UInt24.min) {
            // Overflows over the bounds of our int
            return (partialValue: UInt24(truncatingIfNeeded: r.partialValue), overflow: true)
        }
        
        return (partialValue: UInt24(r.partialValue), overflow: false)
        
    }
    
    public func remainderReportingOverflow(dividingBy rhs: UInt24) -> (partialValue: UInt24, overflow: Bool) {
        /*guard !rhs.isZero else { return (partialValue: self, overflow: true)  }
         
         var selfValue = self
         let rhsValue = rhs
         
         
         
         while selfValue >= rhsValue {
         //print("selfValue: \(selfValue), rhsValue: \(rhsValue)")
         selfValue = selfValue - rhsValue
         }
         
         
         return (partialValue: selfValue, overflow: false)*/
        
        
        guard !rhs.isZero else { return (partialValue: self, overflow: true)  }
        
        let r = UInt32(self).remainderReportingOverflow(dividingBy: UInt32(rhs))
        return (partialValue: UInt24(r.partialValue), overflow: r.overflow)
    }
    
    public func distance(to other: UInt24) -> Int {
        //Taken from https://github.com/apple/swift/blob/master/stdlib/public/core/Integers.swift.gyb
        
        if self > other {
            if let result = Int(exactly: self - other) {
                return -result
            }
        } else {
            if let result = Int(exactly: other - self) {
                return result
            }
        }
        
        preconditionFailure("Distance is not representable in Int")
        //_preconditionFailure("Distance is not representable in Int")
    }
    
    public func advanced(by n: Int) -> UInt24 {
        //Taken from https://github.com/apple/swift/blob/master/stdlib/public/core/Integers.swift.gyb
        
        return (n.isNegative ? (self - UInt24(-n)) : (self + UInt24(n)) )
        
    }
    
    
    public static func == (lhs: UInt24, rhs: UInt24) -> Bool {
        return lhs.bytes == rhs.bytes
    }
    public static func == <Other>(lhs: UInt24, rhs: Other) -> Bool where Other : BinaryInteger {
        /*
         // If the two numbers don't have the same sign, we will return false right away
         guard (lhs.isNegative == rhs.isNegative) else { return false }
         
         //Get raw binary integers and reduce to smalles representation
         // Must reduce otherwise equals will return false if integer value is the same but array sizes are different
         // So if we reduce to the smalles byte size that can represent the integers it makes it easier to compare no
         // matter what integer types we are comparing
         let lhb = IntLogic.minimizeBinaryInteger(lhs.bigEndian.bytes, isSigned: UInt24.isSigned)
         let rhb = IntLogic.minimizeBinaryInteger(rhs.bigEndianBytes, isSigned: Other.isSigned)
         
         
         return (lhb == rhb)*/
        
        return UInt32(lhs) == rhs
    }
    
    public static func != (lhs: UInt24, rhs: UInt24) -> Bool {
        return !(lhs == rhs)
    }
    public static func != <Other>(lhs: UInt24, rhs: Other) -> Bool where Other : BinaryInteger {
        return !(lhs == rhs)
    }
    
    public static func < (lhs: UInt24, rhs: UInt24) -> Bool {
        //return IntLogic.binaryIsLessThan(lhs.bigEndian.bytes, rhs.bigEndianBytes, isSigned: UInt24.isSigned)
        return UInt32(lhs) < UInt32(rhs)
    }
    public static func < <Other>(lhs: UInt24, rhs: Other) -> Bool where Other : BinaryInteger {
        /*
         // -A < B ?
         if lhs.isNegative && !rhs.isNegative { return true }
         // A < -B
         if !lhs.isNegative && rhs.isNegative { return false }
         
         // We don't care about the signed flag on the rhs type because
         // for formulate will be -A < -B || A < B so the sign on A will be the same as the sign on B
         return IntLogic.binaryIsLessThan(lhs.bigEndian.bytes, rhs.bigEndianBytes, isSigned: UInt24.isSigned) */
        
        return UInt32(lhs) < UInt32(rhs)
    }
    
    public static func > (lhs: UInt24, rhs: UInt24) -> Bool {
        //return ((lhs != rhs) && !(lhs < rhs))
        return UInt32(lhs) > UInt32(rhs)
    }
    public static func > <Other>(lhs: UInt24, rhs: Other) -> Bool where Other : BinaryInteger {
        //return ((lhs != rhs) && !(lhs < rhs))
        return UInt32(lhs) > rhs
    }
    
    public static func + (lhs: UInt24, rhs: UInt24) -> UInt24 {
        let r = lhs.addingReportingOverflow(rhs)
        guard !r.overflow else { fatalError("Overflow") }
        return r.partialValue
    }
    
    public static func - (lhs: UInt24, rhs: UInt24) -> UInt24 {
        let r = lhs.subtractingReportingOverflow(rhs)
        guard !r.overflow else { fatalError("Overflow") }
        return r.partialValue
    }
    
    public static func * (lhs: UInt24, rhs: UInt24) -> UInt24 {
        let r = lhs.multipliedReportingOverflow(by: rhs)
        guard !r.overflow else { fatalError("Overflow") }
        return r.partialValue
    }
    
    public static func / (lhs: UInt24, rhs: UInt24) -> UInt24 {
        let r = lhs.dividedReportingOverflow(by: rhs)
        guard !r.overflow else { fatalError("Overflow") }
        return r.partialValue
    }
    
    public static func % (lhs: UInt24, rhs: UInt24) -> UInt24 {
        let r = lhs.remainderReportingOverflow(dividingBy: rhs)
        guard !r.overflow else { fatalError("Overflow") }
        return r.partialValue
    }
    
    public static func & (lhs: UInt24, rhs: UInt24) -> UInt24  {
        var lhb = lhs.bigEndianBytes
        let rhb = rhs.bigEndianBytes
        for i in 0..<lhb.count {
            lhb[i] = lhb[i] & rhb[i]
        }
        
        if !IntLogic.IS_BIGENDIAN { lhb.reverse() }
        
        return UInt24(lhb)
        
    }
    
    public static func | (lhs: UInt24, rhs: UInt24) -> UInt24  {
        var lhb = lhs.bigEndianBytes
        let rhb = rhs.bigEndianBytes
        for i in 0..<lhb.count {
            lhb[i] = lhb[i] | rhb[i]
        }
        
        if !IntLogic.IS_BIGENDIAN { lhb.reverse() }
        
        return UInt24(lhb)
        
    }
    
    public static func ^ (lhs: UInt24, rhs: UInt24) -> UInt24  {
        var lhb = lhs.bigEndianBytes
        let rhb = rhs.bigEndianBytes
        for i in 0..<lhb.count {
            lhb[i] = lhb[i] ^ rhb[i]
        }
        
        if !IntLogic.IS_BIGENDIAN { lhb.reverse() }
        
        return UInt24(lhb)
        
    }
    
    public static func >>(lhs: UInt24, rhs: UInt24) -> UInt24 {
        guard !rhs.isZero else { return lhs }
        var bytes = IntLogic.bitShiftRight(lhs.bigEndian.bytes, count: Int(rhs), isNegative: lhs.isNegative)
        if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
        
        return UInt24(bytes)
        
    }
    
    public static func >><Other>(lhs: UInt24, rhs: Other) -> UInt24 where Other : BinaryInteger {
        guard !rhs.isZero else { return lhs }
        return lhs >> UInt24(rhs)
    }
    
    public static func << (lhs: UInt24, rhs: UInt24) -> UInt24  {
        guard !rhs.isZero else { return lhs }
        var bytes = IntLogic.bitShiftLeft(lhs.bigEndian.bytes, count: Int(rhs), isNegative: lhs.isNegative)
        if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
        
        return UInt24(bytes)
    }
    
    public static func <<<Other>(lhs: UInt24, rhs: Other) -> UInt24 where Other : BinaryInteger {
        guard !rhs.isZero else { return lhs }
        return lhs << UInt24(rhs)
    }
    
    
    public static func += (lhs: inout UInt24, rhs: UInt24) {
        lhs = lhs + rhs
    }
    
    public static func -= (lhs: inout UInt24, rhs: UInt24) {
        lhs = lhs - rhs
    }
    
    public static func *= (lhs: inout UInt24, rhs: UInt24) {
        lhs = lhs * rhs
    }
    
    public static func /= (lhs: inout UInt24, rhs: UInt24) {
        lhs = lhs / rhs
    }
    
    public static func %= (lhs: inout UInt24, rhs: UInt24) {
        lhs = lhs % rhs
    }
    
    public static func |= (lhs: inout UInt24, rhs: UInt24) {
        lhs = lhs | rhs
    }
    
    public static func &= (lhs: inout UInt24, rhs: UInt24) {
        lhs = lhs & rhs
    }
    
    public static func ^= (lhs: inout UInt24, rhs: UInt24) {
        lhs = lhs ^ rhs
    }
    
    
}

#if !swift(>=5.0)
extension UInt24: AdditiveArithmetic { }
#endif
/// MARK: - UInt24 - Codable
extension UInt24: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()
        self = try container.decode(UInt24.self)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self)
    }
}


public struct Int24: FixedWidthInteger, SignedInteger, CustomReflectable {
    
    /// A type that represents an integer literal.
    public typealias IntegerLiteralType = Int32
    
    public struct Words: RandomAccessCollection {
        public typealias Index = Int
        public typealias Element = UInt
        //public typealias Indices = DefaultIndices<Int24.Words>
        //public typealias SubSequence = Slice<Int24.Words>
        
        internal var _value: Int24
        
        public init(_ value: Int24) {
            self._value = value
        }
        
        public let count: Int = 1
        
        public var startIndex: Int = 0
        
        public var endIndex: Int { return count }
        
        //public var indices: Indices { return startIndex ..< endIndex }
        
        @_transparent
        public func index(after i: Int) -> Int { return i + 1 }
        
        @_transparent
        public func index(before i: Int) -> Int { return i - 1 }
        
        public subscript(position: Int) -> UInt {
            guard position == startIndex else { fatalError("Index out of bounds") }
            
            var mutableSource = _value
            let size = MemoryLayout.size(ofValue: mutableSource)
            var bytes: [UInt8] =  withUnsafePointer(to: &mutableSource) {
                return $0.withMemoryRebound(to: UInt8.self, capacity: size) {
                    let buffer = UnsafeBufferPointer(start: $0, count: size)
                    return Array<UInt8>(buffer)
                    
                }
            }
            
            if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
            let isNeg = (Int24.isSigned && bytes[0].hasMinusBit )
            bytes = IntLogic.paddBinaryInteger(bytes, newSizeInBytes: (UInt.bitWidth / 8), isNegative: isNeg)
            
            if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
            
            return bytes.withUnsafeBufferPointer {
                return $0.baseAddress!.withMemoryRebound(to: UInt.self, capacity: 1) {
                    return UInt($0.pointee)
                }
            }
        }
    }
    
    public static let isSigned: Bool = true
    public static let bitWidth: Int = 24
    
    public static let min: Int24 = -8388608
    public static let max: Int24 = 8388607
    
    
    public static let zero: Int24 = Int24()
    internal static let one: Int24 = 1
    
    internal static let minusOne: Int24 = -1
    
    
    /// Creates custom mirror to hide all details about ourselves
    public var customMirror: Mirror { return Mirror(self, children: EmptyCollection()) }
    
    public var words: Int24.Words { return Int24.Words(self) }
    
    /// Returns a count of all non zero bits in the number
    public var nonzeroBitCount: Int {
        return useUnsafeBufferPointer {
            var rtn: Int = 0
            for b in $0 {
                for i in (0..<8) {
                    let mask = UInt8(1 << i)
                    if ((b & mask) == mask) { rtn += 1}
                }
            }
            return rtn
        }
    }
    
    /// Returns a new instances of this number type with our byts reversed
    public var byteSwapped: Int24 {
        
        return useUnsafeBufferPointer {
            var bytes = Array<UInt8>($0)
            bytes.reverse()
            return Int24(bytes)
        }
        
    }
    
    /// Returns the number of leading zeros in this number.  If the number is negative this will return 0
    public var leadingZeroBitCount: Int {
        
        return useUnsafeBufferPointer {
            var range = Array<Int>(0..<$0.count)
            if !IntLogic.IS_BIGENDIAN { range = range.reversed() }
            var foundBit: Bool = false
            var rtn: Int = 0
            for i in range where !foundBit {
                for x in (0..<8).reversed() where !foundBit {
                    let mask = UInt8(1 << x)
                    foundBit = (($0[i] & mask) == mask)
                    if !foundBit { rtn += 1 }
                }
            }
            return rtn
        }
    }
    
    /// Returns the number of trailing zeros in this number
    public var trailingZeroBitCount: Int {
        return useUnsafeBufferPointer {
            var range = Array<Int>(0..<$0.count)
            if IntLogic.IS_BIGENDIAN { range = range.reversed() }
            var foundBit: Bool = false
            var rtn: Int = 0
            for i in range where !foundBit {
                for x in (0..<8).reversed() where !foundBit {
                    let mask = UInt8(1 << x)
                    foundBit = (($0[i] & mask) == mask)
                    if !foundBit { rtn += 1 }
                }
            }
            return rtn
        }
    }
    
    public var magnitude: UInt24 {
        
        if self.isZero { return UInt24() }
        else if self.mostSignificantByte.hasMinusBit {
            
            var bytes = self.bytes
            if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
            bytes = IntLogic.twosComplement(bytes)
            if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
            return UInt24(bytes)
            
        } else { return UInt24(bitPattern: self) }
        
    }
    
    public var bigEndian: Int24 {
        if IntLogic.IS_BIGENDIAN { return self }
        else { return self.byteSwapped }
    }
    
    public var littleEndian: Int24 {
        if !IntLogic.IS_BIGENDIAN { return self }
        else { return self.byteSwapped }
    }
    
    internal var bytes: [UInt8] { return [a, b, c] }
    
    /// Internal property used in basic operations
    fileprivate var iValue: Int {
        /*guard !self.isZero else { return 0 }
         
         var bytes = self.bigEndian.bytes
         bytes = IntLogic.resizeBinaryInteger(bytes, newSizeInBytes: (Int.bitWidth / 8), isNegative: self.isNegative)
         
         if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
         
         let rtn: Int = bytes.withUnsafeBufferPointer {
         return $0.baseAddress!.withMemoryRebound(to: Int.self, capacity: 1) {
         return Int($0.pointee)
         }
         }
         
         return rtn*/
        return Int(self)
    }
    
    #if !swift(>=4.0.9)
    public var hashValue: Int { return self.iValue.hashValue }
    #endif
    
    private var a, b, c: UInt8
    
    public init() {
        
        self.a = 0
        
        self.b = 0
        
        self.c = 0
        
    }
    
    public init(_ other: Int24) {
        
        self.a = other.a
        
        self.b = other.b
        
        self.c = other.c
        
    }
    
    fileprivate init(_ bytes: [UInt8]) {
        let intByteSize: Int = Int24.bitWidth / 8
        precondition(bytes.count == intByteSize, "Byte size missmatch. Expected \(intByteSize), recieved \(bytes.count)")
        self.init()
        
        // Copy bytes into self
        withUnsafeMutablePointer(to: &self) {
            $0.withMemoryRebound(to: UInt8.self, capacity: intByteSize) {
                let buffer = UnsafeMutableBufferPointer(start: $0, count: intByteSize)
                
                for i in 0..<buffer.count {
                    buffer[i] = bytes[i]
                }
            }
        }
        
    }
    
    /// Creates a new instance with the same memory representation as the given
    /// value.
    ///
    /// This initializer does not perform any range or overflow checking. The
    /// resulting instance may not have the same numeric value as
    /// `bitPattern`---it is only guaranteed to use the same pattern of bits in
    /// its binary representation.
    ///
    /// - Parameter x: A value to use as the source of the new instance's binary
    ///   representation.
    public init(bitPattern other: UInt24) {
        precondition(Int24.bitWidth == UInt24.bitWidth, "BitWidth of Int24 and UInt24 do not match")
        
        self.init(other.bytes)
    }
    
    public init(bigEndian value: Int24) {
        var bytes = value.bytes
        if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
        self.init(bytes)
    }
    
    public init(littleEndian value: Int24) {
        var bytes = value.bytes
        if IntLogic.IS_BIGENDIAN { bytes.reverse() }
        self.init(bytes)
    }
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
    
    public init(_truncatingBits truncatingBits: UInt) {
        let typeSize: Int = MemoryLayout<Int24>.size
        var bytes: [UInt8] =  truncatingBits.bytes
        
        if !IntLogic.IS_BIGENDIAN { bytes = bytes.reversed() }
        while bytes.count > typeSize { bytes.remove(at: 0) }
        
        if !IntLogic.IS_BIGENDIAN { bytes = bytes.reversed() }
        
        self.init(bytes)
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        
        // Set required specific integer type information
        let isLocalTypeSigned = Int24.isSigned
        let localBitWidth = Int24.bitWidth
        let localByteWidth = (localBitWidth / 8)
        let intType = Int24.self
        
        var mutableSource = source
        
        let size = MemoryLayout<T>.size
        var bytes: [UInt8] =  withUnsafePointer(to: &mutableSource) {
            return $0.withMemoryRebound(to: UInt8.self, capacity: size) {
                return Array(UnsafeBufferPointer(start: $0, count: size))
            }
        }
        
        if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
        let isNegative = (T.isSigned && bytes[0].hasMinusBit)
        
        if !isLocalTypeSigned && T.isSigned && isNegative {
            fatalError("\(source) is not representable as a '\(intType)' instance")
        } else if isLocalTypeSigned && !T.isSigned && isNegative && bytes.count >= localByteWidth {
            fatalError("Not enough bits to represent a signed value")
        }
        
        bytes = IntLogic.resizeBinaryInteger(bytes, newSizeInBytes: localByteWidth, isNegative: (isNegative && T.isSigned))
        
        guard bytes.count == localByteWidth else { fatalError("Not enough bits to represent a signed value") }
        
        if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
        
        self.init(bytes)
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        let int: Int = Int(source)
        self.init(int)
    }
    #if swift(>=4.2)
    //public func hash(into hasher: inout Hasher) {
    //    self.iValue.hash(into: &hasher)
    //}
    #endif
    
    public func signum() -> Int24 {
        
        if self.isZero { return Int24.zero }
        else if self.mostSignificantByte.hasMinusBit { return Int24.minusOne }
        else { return Int24.one }
        
        
    }
    
    fileprivate mutating func invert() {
        let intByteSize: Int = Int24.bitWidth / 8
        var bytes = self.bytes
        bytes = IntLogic.twosComplement(bytes)
        withUnsafeMutablePointer(to: &self) {
            $0.withMemoryRebound(to: UInt8.self, capacity: intByteSize) {
                let buffer = UnsafeMutableBufferPointer(start: $0, count: intByteSize)
                
                for i in 0..<buffer.count {
                    buffer[i] = bytes[i]
                }
            }
        }
    }
    
    public func addingReportingOverflow(_ rhs: Int24) -> (partialValue: Int24, overflow: Bool) {
        /*guard !rhs.isZero else { return (partialValue: self, overflow: false)  }
         guard !self.isZero else { return (partialValue: rhs, overflow: false)  }
         
         let r = IntLogic.binaryAddition(self.bigEndian.bytes,
         rhs.bigEndian.bytes,
         isSigned: Int24.isSigned)
         
         var bytes = r.partial
         
         if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
         
         let value: Int24 = bytes.withUnsafeBufferPointer {
         return $0.baseAddress!.withMemoryRebound(to: Int24.self, capacity: 1) {
         return Int24($0.pointee)
         }
         }
         return (partialValue: value, overflow: r.overflow)*/
        
        guard !rhs.isZero else { return (partialValue: self, overflow: false) }
        guard !self.isZero else { return (partialValue: rhs, overflow: false) }
        
        let r = Int32(self).addingReportingOverflow(Int32(rhs))
        
        if r.overflow ||
            r.partialValue > Int32(Int24.max) ||
            r.partialValue < Int32(Int24.min) {
            // Overflows over the bounds of our int
            return (partialValue: Int24(truncatingIfNeeded: r.partialValue), overflow: true)
        }
        
        return (partialValue: Int24(r.partialValue), overflow: false)
        
    }
    
    public func subtractingReportingOverflow(_ rhs: Int24) -> (partialValue: Int24, overflow: Bool) {
        /*guard !rhs.isZero else { return (partialValue: self, overflow: false)  }
         
         let r = IntLogic.binarySubtraction(self.bigEndian.bytes,
         rhs.bigEndian.bytes,
         isSigned: Int24.isSigned)
         
         var bytes = r.partial
         
         if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
         
         let value: Int24 = bytes.withUnsafeBufferPointer {
         return $0.baseAddress!.withMemoryRebound(to: Int24.self, capacity: 1) {
         return Int24($0.pointee)
         }
         }
         return (partialValue: value, overflow: r.overflow)*/
        
        guard !rhs.isZero else { return (partialValue: self, overflow: false) }
        guard !(self.isZero && Int24.isSigned) else { return (partialValue: rhs, overflow: false) }
        
        let r = Int32(self).subtractingReportingOverflow(Int32(rhs))
        
        if r.overflow ||
            r.partialValue > Int32(Int24.max) ||
            r.partialValue < Int32(Int24.min) {
            // Overflows over the bounds of our int
            return (partialValue: Int24(truncatingIfNeeded: r.partialValue), overflow: true)
        }
        
        return (partialValue: Int24(r.partialValue), overflow: false)
        
    }
    
    public func multipliedFullWidth(by other: Int24) -> (high: Int24, low: UInt24) {
        /*let r = IntLogic.binaryMultiplication(self.bigEndian.bytes,
         other.bigEndian.bytes,
         isSigned: Int24.isSigned)
         
         let low = r.low.withUnsafeBufferPointer {
         return $0.baseAddress!.withMemoryRebound(to: UInt24.self, capacity: 1) {
         return UInt24(bigEndian: $0.pointee)
         }
         }
         
         let high = r.high.withUnsafeBufferPointer {
         return $0.baseAddress!.withMemoryRebound(to: Int24.self, capacity: 1) {
         return Int24(bigEndian: $0.pointee)
         }
         }
         
         return (high: high, low: low)*/
        
        
        let r = Int32(self).multipliedFullWidth(by: Int32(other))
        
        let val = r.low
        
        let high = val >> Int24.bitWidth
        let low = val - (high << Int24.bitWidth)
        
        return (high: Int24(high), low: UInt24(low))
        
    }
    
    public func multipliedReportingOverflow(by rhs: Int24) -> (partialValue: Int24, overflow: Bool) {
        /*guard !self.isZero && !rhs.isZero else { return (partialValue: Int24(), overflow: false)  }
         
         let r = self.multipliedFullWidth(by: rhs)
         let val = Int24(truncatingIfNeeded: r.low)
         //let val = Int24(bitPattern: r.low)
         var overflow: Bool = false
         if !self.isZero && !rhs.isZero && val.isZero { overflow = true }
         else if !Int24.isSigned && r.high == 1 { overflow = true }
         else if Int24.isSigned && !self.isNegative && !rhs.isNegative && val.isNegative {
         overflow = true
         } else {
         if xor(self.isNegative, rhs.isNegative) && !val.isNegative { overflow = true }
         }
         
         return (partialValue: val, overflow: overflow)*/
        
        guard !self.isZero && !rhs.isZero else { return (partialValue: Int24.zero, overflow: false) }
        
        let r = Int32(self).multipliedReportingOverflow(by: Int32(rhs))
        
        if r.overflow ||
            r.partialValue > Int32(Int24.max) ||
            r.partialValue < Int32(Int24.min) {
            // Overflows over the bounds of our int
            return (partialValue: Int24(truncatingIfNeeded: r.partialValue), overflow: true)
        }
        
        return (partialValue: Int24(r.partialValue), overflow: false)
        
    }
    
    public func dividingFullWidth(_ dividend: (high: Int24, low: Magnitude)) -> (quotient: Int24, remainder: Int24) {
        // We are cheating here.  Instead of using our own code.  we are casting as base Int type
        
        
        let divisor = (dividend.high.iValue << Int24.bitWidth) + Int(dividend.low)
        
        let r = self.iValue.quotientAndRemainder(dividingBy: divisor)
        return (quotient: Int24(r.quotient), remainder: Int24(r.remainder))
        
        
    }
    
    public func dividedReportingOverflow(by rhs: Int24) -> (partialValue: Int24, overflow: Bool) {
        /*// We are cheating here.  Instead of using our own code.  we are casting as base Int type
         guard !self.isZero else { return (partialValue: Int24(), overflow: false)  }
         guard !rhs.isZero else { return (partialValue: self, overflow: true)   }
         
         
         let intValue = self.iValue / rhs.iValue
         let hasOverflow = (intValue > Int24.max.iValue || intValue < Int24.min.iValue)
         return (partialValue: Int24(truncatingIfNeeded: intValue), overflow: hasOverflow)
         */
        
        guard !self.isZero else { return (partialValue: Int24.zero, overflow: false)  }
        guard !rhs.isZero else { return (partialValue: self, overflow: true) }
        
        let r = Int32(self).dividedReportingOverflow(by: Int32(rhs))
        
        if r.overflow ||
            r.partialValue > Int32(Int24.max) ||
            r.partialValue < Int32(Int24.min) {
            // Overflows over the bounds of our int
            return (partialValue: Int24(truncatingIfNeeded: r.partialValue), overflow: true)
        }
        
        return (partialValue: Int24(r.partialValue), overflow: false)
        
    }
    
    public func remainderReportingOverflow(dividingBy rhs: Int24) -> (partialValue: Int24, overflow: Bool) {
        /*guard !rhs.isZero else { return (partialValue: self, overflow: true)  }
         
         var selfValue = self
         let rhsValue = rhs
         
         
         let isSelfNeg = selfValue.isNegative
         if isSelfNeg { selfValue = selfValue * -1  }
         
         
         while selfValue >= rhsValue {
         //print("selfValue: \(selfValue), rhsValue: \(rhsValue)")
         selfValue = selfValue - rhsValue
         }
         
         if isSelfNeg { selfValue = selfValue * -1  }
         
         
         return (partialValue: selfValue, overflow: false)*/
        
        
        guard !rhs.isZero else { return (partialValue: self, overflow: true)  }
        
        let r = Int32(self).remainderReportingOverflow(dividingBy: Int32(rhs))
        return (partialValue: Int24(r.partialValue), overflow: r.overflow)
    }
    
    public func distance(to other: Int24) -> Int {
        //Taken from https://github.com/apple/swift/blob/master/stdlib/public/core/Integers.swift.gyb
        
        let isNeg = self.isNegative
        if isNeg == other.isNegative {
            if let result = Int(exactly: other - self) {
                return result
            }
        } else {
            if let result = Int(exactly: self.magnitude + other.magnitude) {
                return isNegative ? result : -result
            }
        }
        
        preconditionFailure("Distance is not representable in Int")
        //_preconditionFailure("Distance is not representable in Int")
    }
    
    public func advanced(by n: Int) -> Int24 {
        //Taken from https://github.com/apple/swift/blob/master/stdlib/public/core/Integers.swift.gyb
        
        if  (self.isNegative == n.isNegative) { return (self + Int24(n)) }
        
        return (self.magnitude < n.magnitude) ? Int24(Int(self) + n) : (self + Int24(n))
        
    }
    
    
    public static func == (lhs: Int24, rhs: Int24) -> Bool {
        return lhs.bytes == rhs.bytes
    }
    public static func == <Other>(lhs: Int24, rhs: Other) -> Bool where Other : BinaryInteger {
        /*
         // If the two numbers don't have the same sign, we will return false right away
         guard (lhs.isNegative == rhs.isNegative) else { return false }
         
         //Get raw binary integers and reduce to smalles representation
         // Must reduce otherwise equals will return false if integer value is the same but array sizes are different
         // So if we reduce to the smalles byte size that can represent the integers it makes it easier to compare no
         // matter what integer types we are comparing
         let lhb = IntLogic.minimizeBinaryInteger(lhs.bigEndian.bytes, isSigned: Int24.isSigned)
         let rhb = IntLogic.minimizeBinaryInteger(rhs.bigEndianBytes, isSigned: Other.isSigned)
         
         
         return (lhb == rhb)*/
        
        return Int32(lhs) == rhs
    }
    
    public static func != (lhs: Int24, rhs: Int24) -> Bool {
        return !(lhs == rhs)
    }
    public static func != <Other>(lhs: Int24, rhs: Other) -> Bool where Other : BinaryInteger {
        return !(lhs == rhs)
    }
    
    public static func < (lhs: Int24, rhs: Int24) -> Bool {
        //return IntLogic.binaryIsLessThan(lhs.bigEndian.bytes, rhs.bigEndianBytes, isSigned: Int24.isSigned)
        return Int32(lhs) < Int32(rhs)
    }
    public static func < <Other>(lhs: Int24, rhs: Other) -> Bool where Other : BinaryInteger {
        /*
         // -A < B ?
         if lhs.isNegative && !rhs.isNegative { return true }
         // A < -B
         if !lhs.isNegative && rhs.isNegative { return false }
         
         // We don't care about the signed flag on the rhs type because
         // for formulate will be -A < -B || A < B so the sign on A will be the same as the sign on B
         return IntLogic.binaryIsLessThan(lhs.bigEndian.bytes, rhs.bigEndianBytes, isSigned: Int24.isSigned) */
        
        return Int32(lhs) < Int32(rhs)
    }
    
    public static func > (lhs: Int24, rhs: Int24) -> Bool {
        //return ((lhs != rhs) && !(lhs < rhs))
        return Int32(lhs) > Int32(rhs)
    }
    public static func > <Other>(lhs: Int24, rhs: Other) -> Bool where Other : BinaryInteger {
        //return ((lhs != rhs) && !(lhs < rhs))
        return Int32(lhs) > rhs
    }
    
    public static func + (lhs: Int24, rhs: Int24) -> Int24 {
        let r = lhs.addingReportingOverflow(rhs)
        guard !r.overflow else { fatalError("Overflow") }
        return r.partialValue
    }
    
    public static func - (lhs: Int24, rhs: Int24) -> Int24 {
        let r = lhs.subtractingReportingOverflow(rhs)
        guard !r.overflow else { fatalError("Overflow") }
        return r.partialValue
    }
    
    public static func * (lhs: Int24, rhs: Int24) -> Int24 {
        let r = lhs.multipliedReportingOverflow(by: rhs)
        guard !r.overflow else { fatalError("Overflow") }
        return r.partialValue
    }
    
    public static func / (lhs: Int24, rhs: Int24) -> Int24 {
        let r = lhs.dividedReportingOverflow(by: rhs)
        guard !r.overflow else { fatalError("Overflow") }
        return r.partialValue
    }
    
    public static func % (lhs: Int24, rhs: Int24) -> Int24 {
        let r = lhs.remainderReportingOverflow(dividingBy: rhs)
        guard !r.overflow else { fatalError("Overflow") }
        return r.partialValue
    }
    
    public static func & (lhs: Int24, rhs: Int24) -> Int24  {
        var lhb = lhs.bigEndianBytes
        let rhb = rhs.bigEndianBytes
        for i in 0..<lhb.count {
            lhb[i] = lhb[i] & rhb[i]
        }
        
        if !IntLogic.IS_BIGENDIAN { lhb.reverse() }
        
        return Int24(lhb)
        
    }
    
    public static func | (lhs: Int24, rhs: Int24) -> Int24  {
        var lhb = lhs.bigEndianBytes
        let rhb = rhs.bigEndianBytes
        for i in 0..<lhb.count {
            lhb[i] = lhb[i] | rhb[i]
        }
        
        if !IntLogic.IS_BIGENDIAN { lhb.reverse() }
        
        return Int24(lhb)
        
    }
    
    public static func ^ (lhs: Int24, rhs: Int24) -> Int24  {
        var lhb = lhs.bigEndianBytes
        let rhb = rhs.bigEndianBytes
        for i in 0..<lhb.count {
            lhb[i] = lhb[i] ^ rhb[i]
        }
        
        if !IntLogic.IS_BIGENDIAN { lhb.reverse() }
        
        return Int24(lhb)
        
    }
    
    public static func >>(lhs: Int24, rhs: Int24) -> Int24 {
        guard !rhs.isZero else { return lhs }
        var bytes = IntLogic.bitShiftRight(lhs.bigEndian.bytes, count: Int(rhs), isNegative: lhs.isNegative)
        if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
        
        return Int24(bytes)
        
    }
    
    public static func >><Other>(lhs: Int24, rhs: Other) -> Int24 where Other : BinaryInteger {
        guard !rhs.isZero else { return lhs }
        return lhs >> Int24(rhs)
    }
    
    public static func << (lhs: Int24, rhs: Int24) -> Int24  {
        guard !rhs.isZero else { return lhs }
        var bytes = IntLogic.bitShiftLeft(lhs.bigEndian.bytes, count: Int(rhs), isNegative: lhs.isNegative)
        if !IntLogic.IS_BIGENDIAN { bytes.reverse() }
        
        return Int24(bytes)
    }
    
    public static func <<<Other>(lhs: Int24, rhs: Other) -> Int24 where Other : BinaryInteger {
        guard !rhs.isZero else { return lhs }
        return lhs << Int24(rhs)
    }
    
    
    public static func += (lhs: inout Int24, rhs: Int24) {
        lhs = lhs + rhs
    }
    
    public static func -= (lhs: inout Int24, rhs: Int24) {
        lhs = lhs - rhs
    }
    
    public static func *= (lhs: inout Int24, rhs: Int24) {
        lhs = lhs * rhs
    }
    
    public static func /= (lhs: inout Int24, rhs: Int24) {
        lhs = lhs / rhs
    }
    
    public static func %= (lhs: inout Int24, rhs: Int24) {
        lhs = lhs % rhs
    }
    
    public static func |= (lhs: inout Int24, rhs: Int24) {
        lhs = lhs | rhs
    }
    
    public static func &= (lhs: inout Int24, rhs: Int24) {
        lhs = lhs & rhs
    }
    
    public static func ^= (lhs: inout Int24, rhs: Int24) {
        lhs = lhs ^ rhs
    }
    
    
}

#if !swift(>=5.0)
extension Int24: AdditiveArithmetic { }
#endif
/// MARK: - Int24 - Codable
extension Int24: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()
        self = try container.decode(Int24.self)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self)
    }
}


public extension UnkeyedDecodingContainer {
    
    mutating func decode(_ type: UInt24.Type) throws -> UInt24 {
        let value = try self.decode(UInt32.self)
        return UInt24(value)
    }
    
    mutating func decode(_ type: Int24.Type) throws -> Int24 {
        let value = try self.decode(Int32.self)
        return Int24(value)
    }
    
}

public extension SingleValueDecodingContainer {
    
    mutating func decode(_ type: UInt24.Type) throws -> UInt24 {
        let value = try self.decode(UInt32.self)
        return UInt24(value)
    }
    
    mutating func decode(_ type: Int24.Type) throws -> Int24 {
        let value = try self.decode(Int32.self)
        return Int24(value)
    }
    
}

public extension KeyedDecodingContainer {
    
    mutating func decode(_ type: UInt24.Type, forKey key: KeyedDecodingContainer.Key) throws -> UInt24 {
        let value = try self.decode(UInt32.self, forKey: key)
        return UInt24(value)
    }
    
    mutating func decode(_ type: Int24.Type, forKey key: KeyedDecodingContainer.Key) throws -> Int24 {
        let value = try self.decode(Int32.self, forKey: key)
        return Int24(value)
    }
}

public extension UnkeyedEncodingContainer {
    
    mutating func encode(_ value: UInt24) throws {
        try self.encode(UInt32(value))
    }
    
    mutating func encode(_ value: Int24) throws {
        try self.encode(Int32(value))
    }
    
}

public extension SingleValueEncodingContainer {
    
    mutating func encode(_ value: UInt24) throws {
        try self.encode(UInt32(value))
    }
    
    mutating func encode(_ value: Int24) throws {
        try self.encode(Int32(value))
    }
    
}

public extension KeyedEncodingContainer {
    
    mutating func encode(_ value: UInt24, forKey key: Key) throws {
        try self.encode(UInt32(value), forKey: key)
    }
    
    mutating func encode(_ value: Int24, forKey key: Key) throws {
        try self.encode(Int32(value), forKey: key)
    }
}

public extension NSNumber {
    
    @nonobjc
    convenience init(value:  UInt24) {
        self.init(value: UInt32(value))
    }
    
    @nonobjc
    convenience init(value:  Int24) {
        self.init(value: Int32(value))
    }
}
