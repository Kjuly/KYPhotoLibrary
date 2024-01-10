//
//  AssetsViewModelError.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 6/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation

enum AssetsViewModelError: Error {
  case cameraUnavailable
  case failedToAccessCamera
  case failedToSaveAsset(String)
  case unknown
}

extension AssetsViewModelError: LocalizedError {

  var errorDescription: String? {
    switch self {
    case .cameraUnavailable:
      return "Camera Unavailable"
    case .failedToAccessCamera:
      return "Unable to access the Camera."
    case .failedToSaveAsset(let errorMessage):
      return "Failed to save asset.\n\(errorMessage)"
    case .unknown:
      return "Unknown Error"
    }
  }

  var recoverySuggestion: String? {
    switch self {
    case .cameraUnavailable:
      return "Sorry, the Camera is unavailable on the current device."
    case .failedToAccessCamera:
      return "Please go to Settings > Privacy > Camera and turn on Camera access for this demo."
    default:
      return nil
    }
  }
}
