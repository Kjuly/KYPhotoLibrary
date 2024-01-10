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
}
