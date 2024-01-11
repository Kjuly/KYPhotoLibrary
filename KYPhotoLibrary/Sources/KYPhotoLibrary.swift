//
//  KYPhotoLibrary.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 30/6/2016.
//  Copyright © 2016 Kaijie Yu. All rights reserved.
//

import Foundation

public class KYPhotoLibrary {

  // MARK: - Error

  public enum CommonError: Error, LocalizedError {
    case invalidAlbumName(String)
    case albumNotFound(String)
    case assetBelongedAlbumNotFound(String)
    case noAssetProvided
    case assetNotFound(String)
    case failedToSaveAsset
    case failedToAddSavedAssetToAlbum(String)
    case failedToLoadAsset

    public var errorDescription: String? {
      switch self {
      case .invalidAlbumName(let name):
        return "Invalid album name: \"\(name)\"."
      case .albumNotFound(let name):
        return "Album named \"\(name)\" not found."
      case .assetBelongedAlbumNotFound(let assetIdentifier):
        return "Album not found for the asset with identifier: \(assetIdentifier)."
      case .noAssetProvided:
        return "No asset provided."
      case .assetNotFound(let assetIdentifier):
        return "Asset with identifier: \"\(assetIdentifier)\" not found."
      case .failedToSaveAsset:
        return "Failed to save asset."
      case .failedToAddSavedAssetToAlbum(let name):
        return "Failed to add saved asset to album: \(name)."
      case .failedToLoadAsset:
        return "Failed to load asset."
      }
    }
  }
}
