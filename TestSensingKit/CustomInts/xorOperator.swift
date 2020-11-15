//
//  xorOperator.swift
//  CustomInts
//
//  Created by Kseniia Shkurenko on 09.11.2020.
//

import Foundation

internal func xor(_ lhs: @autoclosure () -> Bool, _ rhs: @autoclosure () -> Bool) -> Bool {
    let lhB = lhs()
    let rhB = rhs()
    return ((lhB && !rhB) || (!lhB && rhB))
}
