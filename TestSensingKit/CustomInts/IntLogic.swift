//
//  IntLogic.swift
//  CustomInts
//
//  Created by Kseniia Shkurenko on 09.11.2020.
//

import Foundation

internal struct IntLogic {

    /// An indicator if the system we're running on uses Big Endian
    public static let IS_BIGENDIAN: Bool = {
        let number: UInt32 = 0x12345678
        let converted = number.bigEndian
        return (number == converted)
    }()

    /// An indicator if the system we're running on uses Little Endian
    public static let IS_LITTLEENDIAN: Bool = { return !IS_BIGENDIAN }()
    
}

// MARK:- Basic Logic
internal extension IntLogic {
    /// Generate two's complement of the big endian integer
    static func twosComplement(_ bytes: [UInt8]) -> [UInt8] {
        var rtn: [UInt8] = bytes
        for i in 0..<rtn.count { rtn[i] = ~rtn[i] }
        var addOne: Bool = true
        for i in (0..<rtn.count).reversed() where addOne {
            addOne = false
            if (Int(rtn[i]) + 1) > Int(UInt8.max) {
                rtn[i] = 0
                addOne = true
            } else {
                rtn[i] = rtn[i] + 1
            }
        }
        return rtn
    }
    
    static func resizeBinaryInteger(_ bigEndianInteger: [UInt8], newSizeInBytes: Int, isNegative: Bool) -> [UInt8] {
        if newSizeInBytes > bigEndianInteger.count {
            return paddBinaryInteger(bigEndianInteger, newSizeInBytes: newSizeInBytes, isNegative: isNegative)
        } else if newSizeInBytes < bigEndianInteger.count {
            return reduceBinaryInteger(bigEndianInteger, newSizeInBytes: newSizeInBytes, isNegative: isNegative)
        } else {
            return bigEndianInteger
        }
    }

    /// Padds the big endian integer to a new size if current size is smaller.
    /// Padding value is 0x00 if number is positive and 0xFF if the number is negative
    static func paddBinaryInteger(_ bigEndianInteger: [UInt8], newSizeInBytes: Int, isNegative: Bool) -> [UInt8] {
        var rtn: [UInt8] = bigEndianInteger
        let padding: UInt8 = (isNegative) ? 0xFF : 0x00
        let diff = newSizeInBytes - rtn.count
        if diff > 0 {
            rtn.insert(contentsOf: [UInt8](repeating: padding, count: diff), at: 0)
        }
        return rtn
    }
    
    /// reductes the big endian integer to a new size if current size is bigger and can be reduced
    static func reduceBinaryInteger(_ bigEndianInteger: [UInt8], newSizeInBytes: Int, isNegative: Bool) -> [UInt8] {
        var rtn: [UInt8] = bigEndianInteger
        let padding: UInt8 = (isNegative) ? 0xFF : 0x00
        while rtn.count > newSizeInBytes && rtn[0] == padding { rtn.removeFirst() }
        return rtn
    }
    
    

    /// Reduces the big endian integer to its smallest byte size while retaining the origional value.
    /// If the number is a signed type and has a negative indicator this will keep removing the first byte while it equals 0xFF.
    /// Otherwise if the number is a positive number this will keep removing the first byte while it equals 0x00.
    /// If the results is an empty byte array then the last byte that we removed will be put back. (this happens for values of 0 and values of -1)
    static func minimizeBinaryInteger(_ bigEndianInteger: [UInt8], isSigned: Bool) -> [UInt8] {
        var rtn: [UInt8] = bigEndianInteger
        let padding: UInt8 = (isSigned && bigEndianInteger[0].hasMinusBit) ? 0xFF : 0x00
        while rtn.count > 1 && rtn[0] == padding { rtn.removeFirst() }
        return rtn
    }

    /// Counts the number of leading zero bits from a big endian integer
    static func leadingZeroBitCount(_ bigEndianInteger: [UInt8]) -> Int {
        var foundBit: Bool = false
        var rtn: Int = 0
        for i in (0..<bigEndianInteger.count) where !foundBit {
            for x in (0..<8).reversed() where !foundBit {
                let mask = UInt8(1 << x)
                foundBit = ((bigEndianInteger[i] & mask) == mask)
                if !foundBit { rtn += 1 }
            }
        }
        return rtn
    }

    /// Provides an indicator if the bit at the given location is 1.
    /// bit order goes from least significant bit to most significant bit
    static func hasBit(at location: Int, in bytes: [UInt8]) -> Bool {
        precondition(location >= 0, "Location must be >= 0")
        precondition(location < (bytes.count * 8), "Index out of bounds")
        var bts = bytes
        var idx = location
        while idx > 7 {
            bts.removeLast()
            idx = idx - 8
        }
        let mask: UInt8 = 1 << idx
        return ((bts.last! & mask) == mask)
    }
    /// Provides an indicator if the bit at the given location is 1.
    /// bit order goes from least significant bit to most significant bit
    static func hasBit(at location: Int, in byte: UInt8) -> Bool {
        return hasBit(at: location, in: [byte])
    }


    /// Converts the byte array into a binary string
    static func getBinaryString(for value: [UInt8]) -> String {
        var rtn: String = ""
        for b in value {
            var s = String(b, radix: 2)
            while s.count < UInt8.bitWidth { s = "0" + s }
            rtn += s
        }
        return rtn
    }

}

// MARK:- Operators
internal extension IntLogic {
    /// Right bit shift of a big endian integer in byte format
    static func bitShiftRight(_ bigEndianInt: [UInt8], count: Int, isNegative: Bool) -> [UInt8] {
        guard count != 0 else { return bigEndianInt  }
        guard count > 0 else { return bitShiftLeft(bigEndianInt, count: (count * -1), isNegative: isNegative) }
        
        //Trying to shift larger then the actual number.  This results in all zeros for positive and all ones for negative
        guard count < (bigEndianInt.count * 8) else {
            let padding: UInt8 = isNegative ? 0xFF : 0x00
            return [UInt8](repeating: padding, count: bigEndianInt.count)
        }
        
        var bytes = bigEndianInt
        var cnt = count
        
        //Do large shift while whole bytes are involved
        let byteShift = (cnt - (cnt % 8)) / 8
        if byteShift > 0 {
            bytes.removeLast(byteShift)
            let padding: UInt8 = isNegative ? 0xFF : 0x00
            bytes.insert(contentsOf: [UInt8](repeating: padding, count: byteShift), at: 0)
            cnt = cnt - (byteShift * 8)
        }
        
        // Shift individual bits
        for _ in 0..<cnt {
            for i in (0..<bytes.count).reversed() {
                bytes[i] = bytes[i] >> 1
                if i == 0 && isNegative { bytes[i] = bytes[i] | 0x80 }
                else if i > 0 {
                    if ((bytes[i-1] & 0x01) == 0x01) {
                        bytes[i] = bytes[i] | 0x80
                    }
                }
            }
        }
        
        return bytes
        
        
    }

    /// Left bit shift of a big endian integer in byte format
    static func bitShiftLeft(_ bigEndianInt: [UInt8], count: Int, isNegative: Bool) -> [UInt8] {
        guard count != 0 else { return bigEndianInt  }
        guard count > 0 else { return bitShiftRight(bigEndianInt, count: (count * -1), isNegative: isNegative) }
        
        //Trying to shift larger then the actual number.  This results in all zeros
        guard count < (bigEndianInt.count * 8) else { return [UInt8](repeating: 0x00, count: bigEndianInt.count) }
        
        var bytes = bigEndianInt
        var cnt = count
        
        //Do large shift while whole bytes are involved
        let byteShift = (cnt - (cnt % 8)) / 8
        if byteShift > 0 {
            bytes.removeLast(byteShift)
            bytes.insert(contentsOf: [UInt8](repeating: 0x00, count: byteShift), at: 0)
            cnt = cnt - (byteShift * 8)
        }
        
        
        // Shift individual bits
        for _ in 0..<cnt {
            for i in (0..<bytes.count) {
                bytes[i] = bytes[i] << 1
                if i < (bytes.count - 1) && ((bytes[i+1] & 0x80) == 0x80) {
                    bytes[i] = bytes[i] | 0x01
                }
            }
        }
        
        return bytes
    }

    /// Big Endian integer addition base in byte format returning results and remainder indicator.  Does not do any overflow detection
    static func binaryAdditionBase(_ lhs: [UInt8], _ rhs: [UInt8]) -> (partial: [UInt8], overflow: Bool) {
        var rtn = lhs
        
        guard lhs.count == rhs.count else { fatalError("Int size missmatch") }
        
        
        var hasRemainder: Bool = false
        for byteIndex in (0..<rtn.count).reversed() {
            let addition: UInt16 = (hasRemainder ? 1 : 0 ) + UInt16(rhs[byteIndex])
            hasRemainder = false
            var newVal = UInt16(rtn[byteIndex]) + addition
            if newVal > UInt8.max {
                hasRemainder = true
                newVal = newVal - 256
            }
            rtn[byteIndex] = UInt8(newVal)
        }
        
        
        return (partial: rtn, overflow: hasRemainder)
        
    }

    /// Big Endian integer addition in byte format returning results and overflow indicator
    static func binaryAddition(_ lhs: [UInt8], _ rhs: [UInt8], isSigned signed: Bool) -> (partial: [UInt8], overflow: Bool) {
        // If lhs = A and rhs = -A then the formula would be A + -A. That means that the result will be 0
        // So instead of doing the calculation.  Lets just return 0
        guard !(signed && lhs == twosComplement(rhs)) else {
            return  (partial: [UInt8](repeating: 0x00, count: lhs.count), overflow: false)
        }
        
        let r = binaryAdditionBase(lhs, rhs)
        var o = r.overflow
        
        if signed {
            // -A + B = +C || B - A = +C
            if o && xor(lhs[0].hasMinusBit, rhs[0].hasMinusBit) && !r.partial[0].hasMinusBit { o = false }
            else if !o && !lhs[0].hasMinusBit && !rhs[0].hasMinusBit && r.partial[0].hasMinusBit { o = true } // Rolled over ma from positive to negative
            
        }
        
        /*var printLn: String = ""
         printLn += "   " + getBinaryString(for: lhs) + "\n"
         printLn += " + " + getBinaryString(for: rhs) + "\n"
         printLn += "   " + String(repeating: "_", count: (lhs.count * 8)) + "\n"
         
         printLn += "   " + getBinaryString(for: r.partial) + "  hasRemainder: \(o)" + "\n"
         
         if (o) { print(printLn) }*/
        
        return (partial: r.partial, overflow: o)
    }

    /// Big Endian integer subtraction in byte format returning results and overflow indicator
    static func binarySubtraction(_ lhs: [UInt8], _ rhs: [UInt8], isSigned signed: Bool) -> (partial: [UInt8], overflow: Bool) {
        
        // Zero Sum check
        // If lhs = A and rhs = A then the formula would be A - A. That means that the result will be 0
        // So instead of doing the calculation.  Lets just return 0
        guard !(lhs == rhs) else {
            return  (partial: [UInt8](repeating: 0x00, count: lhs.count), overflow: false)
        }
        
        
        let r = binaryAdditionBase(lhs, twosComplement(rhs))
        var o = r.overflow
        
        if !signed {
            if !o && !lhs[0].hasMinusBit && !rhs[0].hasMinusBit && r.partial[0].hasMinusBit { o = true }
            else if o && lhs[0].hasMinusBit && !rhs[0].hasMinusBit && !r.partial[0].hasMinusBit { o = false }
            else if o && !lhs[0].hasMinusBit && !rhs[0].hasMinusBit && !r.partial[0].hasMinusBit { o = false }
            else if o && xor(lhs[0].hasMinusBit, rhs[0].hasMinusBit) && r.partial[0].hasMinusBit { o = false }
        } else {
            if o && xor(lhs[0].hasMinusBit, rhs[0].hasMinusBit) && r.partial[0].hasMinusBit { o = false }
            else if o && !lhs[0].hasMinusBit && !rhs[0].hasMinusBit && !r.partial[0].hasMinusBit { o = false } // MAX - 1
            
        }
        
        /*var printLn: String = ""
         printLn += "   " + getBinaryString(for: lhs) + "\n"
         printLn += " - " + getBinaryString(for: rhs) + "\n"
         printLn += "   " + String(repeating: "_", count: (lhs.count * 8)) + "\n"
         
         printLn += "   " + getBinaryString(for: r.partial) + "  hasRemainder: \(o)" + "\n"
         
         if (o) { print(printLn) }*/
        
        return (partial: r.partial, overflow: o)
        
    }

    /// Big Endian integer multiplication in byte format returning high and low order
    static func binaryMultiplication(_ lhs: [UInt8], _ rhs: [UInt8], isSigned signed: Bool) -> (high: [UInt8], low: [UInt8]) {
        var lhB = lhs
        var rhB = rhs
        
        let lhvNeg = (signed && lhs[0].hasMinusBit)
        let rhvNeg = (signed && rhs[0].hasMinusBit)
        //Reduce both numbers to their smallest byte form
        lhB = minimizeBinaryInteger(lhB, isSigned: signed)
        rhB = minimizeBinaryInteger(rhB, isSigned: signed)
        
        let isResultsNegative: Bool = xor(lhvNeg, rhvNeg)
        
        //Multiplying two negatives is the same as multiplying two positives
        // -A * -B ~ A * B
        /*if lhvNeg && rhvNeg {
            lhB = twosComplement(lhB)
            rhB = twosComplement(rhB)
            lhvNeg = false
            rhvNeg = false
        }*/
        if lhvNeg {
            // We will do multiplication all in positive numbers and just turn in negative at the end
            lhB = twosComplement(lhB)
        }
        if rhvNeg {
            // We will do multiplication all in positive numbers and just turn in negative at the end
            rhB = twosComplement(rhB)
        }
        
        
        let largestBytesSize = max(lhB.count, rhs.count)
        
        lhB = paddBinaryInteger(lhB, newSizeInBytes: largestBytesSize, isNegative: false)
        rhB = paddBinaryInteger(rhB, newSizeInBytes: largestBytesSize, isNegative: false)
        
        
        let rhActiveBits = (largestBytesSize * 8) - leadingZeroBitCount(rhB)
        var newBufferBitSize = (largestBytesSize * 8) + rhActiveBits
        while (newBufferBitSize % 8 != 0) { newBufferBitSize += 1  }
        let newBufferSize = (newBufferBitSize / 8)
        
        var additionBuffer: [[UInt8]] = []
        for i in 0..<rhActiveBits {
            let hasB = hasBit(at: i, in: rhs)
            var value: [UInt8]
            
            if !hasB { value = [UInt8](repeating: 0x00, count: newBufferSize)  }
            else { value = paddBinaryInteger(lhB, newSizeInBytes: newBufferSize, isNegative: false) }
            value = bitShiftLeft(value, count: i, isNegative: false)
            additionBuffer.append(value)
        }
        
        var finalBinaryValue: [UInt8] = [UInt8](repeating: 0x00, count: newBufferSize)
        var hasOverflow: Bool = false
        for v in additionBuffer where !hasOverflow {
            let r = binaryAddition(finalBinaryValue, v, isSigned: signed)
            
            //let r = binaryAddition(finalBinaryValue, v)
            hasOverflow = r.overflow
            finalBinaryValue = r.partial
        }
        
        // one of the multiplied numbers was negative so we must make our number negative
        if isResultsNegative { finalBinaryValue = twosComplement(finalBinaryValue) }
        
        finalBinaryValue = paddBinaryInteger(finalBinaryValue, newSizeInBytes: (lhs.count * 2), isNegative: isResultsNegative)
        //finalBinaryValue = paddBinaryInteger(finalBinaryValue, newSizeInBytes: (lhs.count * 2), isSigned: signed)
        let highBytes = finalBinaryValue[0 ..< lhs.count]
        let lowBytes = finalBinaryValue[lhs.count ..< finalBinaryValue.count]
        
        /*var printLn: String = ""
        printLn += "   " + getBinaryString(for: paddBinaryInteger(lhs, newSizeInBytes: (lhs.count * 2), isNegative: lhvNeg)) + "\n"
        printLn += " * " + getBinaryString(for: paddBinaryInteger(rhs, newSizeInBytes: (lhs.count * 2), isNegative: rhvNeg)) + "\n"
        printLn += "   " + String(repeating: "_", count: (lhs.count * 8)) + "\n"
     
        printLn += "   " + getBinaryString(for: finalBinaryValue) + "\n"
        
        print(printLn)
        
        if xor(lhvNeg, rhvNeg) {
            printLn = ""
            printLn += "   " + getBinaryString(for: paddBinaryInteger(lhB, newSizeInBytes: (lhs.count * 2), isNegative: lhvNeg)) + "\n"
            printLn += " * " + getBinaryString(for: paddBinaryInteger(rhB, newSizeInBytes: (lhs.count * 2), isNegative: rhvNeg)) + "\n"
            printLn += "   " + String(repeating: "_", count: (lhs.count * 8)) + "\n"
            
            printLn += "   " + getBinaryString(for: finalBinaryValue) + "\n"
            
            print(printLn)
        }*/
        
        //print("high: \(getBinaryString(for: Array(highBytes))), low: \(getBinaryString(for: Array(lowBytes)))")
        
        return (high: Array(highBytes), low: Array(lowBytes))
        
        
    }

    /// Big Endian integer less than operator.  checks to see if first integer is less than the second
    static func binaryIsLessThan(_ lhs: [UInt8], _ rhs: [UInt8], isSigned signed: Bool) -> Bool {
        // A == B
        guard !(lhs == rhs) else { return false }
        let lhvNeg = (signed && lhs[0].hasMinusBit)
        let rhvNeg = (signed && rhs[0].hasMinusBit)
        // -A < B
        if lhvNeg && !rhvNeg { return true }
        // A < -B
        if !lhvNeg && rhvNeg { return false }
        
        
        // Make integers the smalles byte size they can be
        var lhv = minimizeBinaryInteger(lhs, isSigned: signed)
        var rhv = minimizeBinaryInteger(rhs, isSigned: signed)
        
        let largestBytesSize = max(lhv.count, rhv.count)
        
        //padd integers so they are the same size
        lhv = paddBinaryInteger(lhv, newSizeInBytes: largestBytesSize, isNegative: lhvNeg)
        rhv = paddBinaryInteger(rhv, newSizeInBytes: largestBytesSize, isNegative: rhvNeg)
        
        for i in (0..<(lhv.count * 8)).reversed() {
            let lhB = hasBit(at: i, in: lhv)
            let rhB = hasBit(at: i, in: rhv)
            
            if lhB != rhB { return rhB }
        }
        
        return false
    }
}
