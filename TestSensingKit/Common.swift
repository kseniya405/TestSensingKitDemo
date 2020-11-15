//
//  Common.swift
//  BinaryData
//
//  Created by Kseniia Shkurenko on 09.11.2020.
//

import Foundation

func unsafeConversion<FROM, TO>(_ from: FROM) -> TO {
  func ptr(_ fromPtr: UnsafePointer<FROM>) -> UnsafePointer<TO> {
    return fromPtr.withMemoryRebound(to: TO.self, capacity: 1, {  return $0 })
  }
  
  var fromVar = from
  return ptr(&fromVar).pointee
}
