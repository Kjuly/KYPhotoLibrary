//
//  KYPhotoLibraryDebug.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 11/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation

#if DEBUG
enum KYPhotoLibraryDebug {

  struct DuringOptions: OptionSet {
    let rawValue: Int

    static let none = DuringOptions([])
    static let assetQuery  = DuringOptions(rawValue: 1 << 0)
    static let assetExport = DuringOptions(rawValue: 1 << 1)

    static let all: DuringOptions = [.assetQuery, .assetExport]
  }

  private static let activeOptions: DuringOptions = []

  static func simulateWaiting(_ option: DuringOptions, seconds: Double = 3) {
    guard activeOptions.contains(option) else {
      return
    }
    Task {
      try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
  }
}
#endif
