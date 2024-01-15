//
//  KYPhotoLibrary.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 30/6/2016.
//  Copyright © 2016 Kaijie Yu. All rights reserved.
//

import Foundation

public class KYPhotoLibrary {

  // MARK: - Album Error

  public enum AlbumError: Error, LocalizedError {
    /// Invalid album "`name`".
    case invalidName(String)

    /// No album named "`name`" found.
    case albumNotFound(String)

    /// No album found for asset with "`assetIdentifier`".
    case albumNotFoundForAsset(String)

    /// Error description.
    public var errorDescription: String? {
      switch self {
      case .invalidName(let name):
        return "Invalid album name: \"\(name)\"."
      case .albumNotFound(let name):
        return "No album named \"\(name)\" found."
      case .albumNotFoundForAsset(let assetIdentifier):
        return "Album not found for asset with identifier: \(assetIdentifier)."
      }
    }
  }

  // MARK: - Asset Error

  public enum AssetError: Error, LocalizedError {
    /// Unsupported media type.
    case unsupportedMediaType(Int)

    /// No asset provided.
    case noAssetProvided

    /// Asset not found with the "`assetIdentifier`".
    case assetNotFound(String)

    /// Failed to save asset to Photo Library.
    case failedToSaveAssetToPhotoLibrary

    /// Failed to add saved asset to album named "`name`".
    case failedToAddSavedAssetToAlbum(String)

    /// Failed to load asset from Photo Library.
    case failedToLoadAsset

    /// Error description.
    public var errorDescription: String? {
      switch self {
      case .unsupportedMediaType(let type):
        return "Unsupported media type: \(type)."
      case .noAssetProvided:
        return "No asset provided."
      case .assetNotFound(let assetIdentifier):
        return "Asset with identifier: \"\(assetIdentifier)\" not found."
      case .failedToSaveAssetToPhotoLibrary:
        return "Failed to save asset to Photo Library."
      case .failedToAddSavedAssetToAlbum(let name):
        return "Failed to add saved asset to album: \(name)."
      case .failedToLoadAsset:
        return "Failed to load asset."
      }
    }
  }
}
