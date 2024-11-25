//
//  KYPhotoLibrary+AssetChange.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 11/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import Photos

#if os(iOS)
import UIKit
#endif

extension KYPhotoLibrary {

  // MARK: - Public - Save Asset to Photo Library

  /// Save an asset with a URL to Photo Library album.
  ///
  /// - Parameters:
  ///   - imageURL: The URL of the asset to save.
  ///   - albumName: Custom album name.
  ///
  /// - Returns: Saved asset's localIdentifier.
  ///
  public static func saveAsset(for mediaType: PHAssetMediaType, with assetURL: URL, toAlbum albumName: String) async throws -> String {
    if mediaType == .image {
      return try await asset_save(image: nil, imageURL: assetURL, videoURL: nil, toAlbum: albumName)
    } else if mediaType == .video {
      return try await asset_save(image: nil, imageURL: nil, videoURL: assetURL, toAlbum: albumName)
    } else {
      throw AssetError.unsupportedMediaType(mediaType.rawValue)
    }
  }

  // MARK: - Internal

  /// **[PKG Internal Usage Only]** Save an image or video to custom album.
  ///
  /// - Parameters:
  ///   - image: The image to save.
  ///   - imageURL: The URL of the image to save.
  ///   - videoURL: The URL of the video to save.
  ///   - albumName: Custom album name.
  ///
  /// - Returns: Saved asset's localIdentifier.
  ///
  static func asset_save(image: KYPhotoLibraryImage?, imageURL: URL?, videoURL: URL?, toAlbum albumName: String?) async throws -> String {
    if image == nil && imageURL == nil && videoURL == nil {
      throw AssetError.noAssetProvided
    }

    var albumAssetCollection: PHAssetCollection?
    if let albumName {
      albumAssetCollection = try await getAlbum(with: albumName)
      if albumAssetCollection == nil {
        throw AlbumError.albumNotFound(albumName)
      }
    }

    let savedAssetIdentifier: String = try await withCheckedThrowingContinuation { continuation in
      PHPhotoLibrary.shared().performChanges {
        // Save asset
        var createAssetRequest: PHAssetChangeRequest?
        if let image {
          createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
        } else if let imageURL {
          createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: imageURL)
        } else if let videoURL {
          createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }

        guard
          let createAssetRequest,
          let placeholderForCreatedAsset: PHObjectPlaceholder = createAssetRequest.placeholderForCreatedAsset
        else {
          continuation.resume(throwing: AssetError.failedToSaveAssetToPhotoLibrary)
          return
        }
        KYPhotoLibraryLog("Save asset succeeded.")

        // Also, try to add the saved asset to the custom album.
        guard
          let albumAssetCollection,
          let collectionChangeRequest = PHAssetCollectionChangeRequest(for: albumAssetCollection)
        else {
          continuation.resume(throwing: AssetError.failedToAddSavedAssetToAlbum(albumName ?? ""))
          return
        }
        collectionChangeRequest.addAssets([placeholderForCreatedAsset] as NSFastEnumeration)
        KYPhotoLibraryLog("Add saved asset to custom album succeeded.")
        continuation.resume(returning: placeholderForCreatedAsset.localIdentifier)
      }
    }
    return savedAssetIdentifier
  }

  /// **[PKG Internal Usage Only]** Delete an asset from Photo Library.
  ///
  /// - Parameters:
  ///   - mediaType: The expected media type of the asset.
  ///   - assetIdentifier: The asset's unique identifier used in the Photo Library.
  ///
  static func asset_delete(for mediaType: PHAssetMediaType, with assetIdentifier: String) async throws {
    guard let asset: PHAsset = await asset(with: assetIdentifier, for: mediaType) else {
      throw AssetError.assetNotFound(assetIdentifier)
    }

    try await PHPhotoLibrary.shared().performChanges {
      PHAssetChangeRequest.deleteAssets([asset] as NSFastEnumeration)
    }
    KYPhotoLibraryLog("Delete asset succeeded.")
  }
}
