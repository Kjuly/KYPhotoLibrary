//
//  URL+KYPhotoLibrary.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 9/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers

extension URL {

  // MARK: - Get File Extension

  /// Get the file extension from an existing file.
  public func ky_getExistingFileExtension() throws -> String? {
    guard let isReachable = try? checkResourceIsReachable(), isReachable else {
      return nil
    }

    var contentType: AnyObject?
    try (self as NSURL).getResourceValue(&contentType, forKey: .contentTypeKey)

    guard let contentType else {
      return nil
    }

    if let type = contentType as? UTType {
      return type.ky_getFileExtension()
    } else if let string = contentType as? String {
      return string
    } else {
      return nil
    }
  }
}
