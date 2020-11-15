//
//  Tupple.swift
//  BinaryData
//
//  Created by Kseniia Shkurenko on 09.11.2020.
//

import Foundation

func applyOrder<T>(_ tuple: (T, T), _ bigEndian: Bool) -> (T, T) {
  return bigEndian ? (tuple.1, tuple.0) : tuple
}

func applyOrder<T>(_ tuple: (T, T, T, T), _ bigEndian: Bool) -> (T, T, T, T) {
  return bigEndian ? (tuple.3, tuple.2, tuple.1, tuple.0) : tuple
}

func applyOrder<T>(_ tuple: (T, T, T), _ bigEndian: Bool) -> (T, T, T) {
  return bigEndian ? (tuple.2, tuple.1, tuple.0) : tuple
}

func applyOrder<T>(_ tuple: (T, T, T, T, T, T, T, T), _ bigEndian: Bool) -> (T, T, T, T, T, T, T, T) {
  return bigEndian ? (tuple.7, tuple.6, tuple.5, tuple.4, tuple.3, tuple.2, tuple.1, tuple.0) : tuple
}

func toUInt16(_ tuple: (UInt8, UInt8)) -> (UInt16, UInt16) {
  return (UInt16(tuple.0), UInt16(tuple.1))
}

func toUInt24(_ tuple: (UInt8, UInt8, UInt8)) -> (UInt24, UInt24, UInt24) {
  return (UInt24(tuple.0), UInt24(tuple.1), UInt24(tuple.2))
}

func toUInt32(_ tuple: (UInt8, UInt8, UInt8, UInt8)) -> (UInt32, UInt32, UInt32, UInt32) {
  return (UInt32(tuple.0), UInt32(tuple.1), UInt32(tuple.2), UInt32(tuple.3))
}

func toUInt64(_ tuple: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)) -> (UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64) {
  return (UInt64(tuple.0), UInt64(tuple.1), UInt64(tuple.2), UInt64(tuple.3), UInt64(tuple.4), UInt64(tuple.5), UInt64(tuple.6), UInt64(tuple.7))
}
