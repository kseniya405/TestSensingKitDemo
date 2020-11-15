//
//  BinaryDataErrors.swift
//  BinaryData
//
//  Created by Kseniia Shkurenko on 09.11.2020.
//

import Foundation

/**
 Errors thrown by `BinaryData` i `BinaryDataReader`
 */
public enum BinaryDataErrors : Error {
  ///There wasn't enough data to read in current `BinaryData` struct
  case notEnoughData
  ///Data was supposed to be UTF8, but there was an error parsing it
  case failedToConvertToString
}
