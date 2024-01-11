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
  case failedToDeleteCachedAsset(String)
  case failedTosaveAssetToAlbum(String)
  case failedToDeleteAssetFromPhotoLibrary(String)
  case unknown
}

extension AssetDetailsViewModelError: LocalizedError {

  var errorDescription: String? {
    switch self {
    case .failedToCacheAsset(let errorMessage):
      return "Failed to cache asset, error: \(errorMessage)."
    case .failedToDeleteCachedAsset(let errorMessage):
      return "Failed to delete cached asset, error: \(errorMessage)."
    case .failedTosaveAssetToAlbum(let errorMessage):
      return "Failed to save asset to Photo Library, error: \(errorMessage)."
    case .failedToDeleteAssetFromPhotoLibrary(let errorMessage):
      return "Failed to delete asset from Photo Library, error: \(errorMessage)."
    case .unknown:
      return "Unknown Error"
    }
  }
}
