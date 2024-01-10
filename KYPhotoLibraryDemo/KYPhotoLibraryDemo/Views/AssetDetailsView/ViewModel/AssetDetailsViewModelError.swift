//
//  AssetDetailsViewModelError.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 8/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation

enum AssetDetailsViewModelError: Error {
  case failedToCacheAsset(String)
  case unknown
}

extension AssetDetailsViewModelError: LocalizedError {

  var errorDescription: String? {
    switch self {
    case .failedToCacheAsset(let errorMessage):
      return "Failed to cache asset.\n\(errorMessage)"
    case .unknown:
      return "Unknown Error"
    }
  }

//  var recoverySuggestion: String? {
//    switch self {
//    case .cameraUnavailable:
//      return "Sorry, the Camera is unavailable on the current device."
//    case .failedToAccessCamera:
//      return "Please go to Settings > Privacy > Camera and turn on Camera access for this demo."
//    default:
//      return nil
//    }
//  }
}
