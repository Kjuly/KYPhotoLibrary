//
//  KYPhotoLibraryError.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 10/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation

public enum KYPhotoLibraryError: Error {
  case assetNotFound(String)
  case failedToPrepareExportSession
  case others(String)
}

extension KYPhotoLibraryError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .assetNotFound(let assetIdentifier):
      return "Asset with identifier: \"\(assetIdentifier)\" not found."
    case .failedToPrepareExportSession:
      return "Failed to prepare export session."
    case .others(let errorMessage):
      return errorMessage
    }
  }
}
