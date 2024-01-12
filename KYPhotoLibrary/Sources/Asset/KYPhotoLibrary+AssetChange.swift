//
//  KYPhotoLibrary+AssetChange.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 11/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import UIKit
import Photos

extension KYPhotoLibrary {

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
  static func asset_save(image: UIImage?, imageURL: URL?, videoURL: URL?, toAlbum albumName: String) async throws -> String {
    if image == nil && imageURL == nil && videoURL == nil {
      throw CommonError.noAssetProvided
    } else if albumName.isEmpty {
      throw CommonError.invalidAlbumName(albumName)
    }

    let assetCollection: PHAssetCollection = try await getAlbum(with: albumName)
    let saveAssetIdentifier: String = try await withCheckedThrowingContinuation { continuation in
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
          continuation.resume(throwing: CommonError.failedToSaveAsset)
          return
        }
        KYPhotoLibraryLog("Save asset succeeded.")

        // Also, try to add the saved asset to the custom album.
        guard let collectionChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection) else {
          continuation.resume(throwing: CommonError.failedToAddSavedAssetToAlbum(albumName))
          return
        }
        collectionChangeRequest.addAssets([placeholderForCreatedAsset] as NSFastEnumeration)
        KYPhotoLibraryLog("Add saved asset to custom album succeeded.")
        continuation.resume(returning: placeholderForCreatedAsset.localIdentifier)
      }
    }
    return saveAssetIdentifier
  }

  /// **[PKG Internal Usage Only]** Delete an asset from Photo Library.
  ///
  /// - Parameters:
  ///   - mediaType: The expected media type of the asset.
  ///   - assetIdentifier: The asset's unique identifier used in the Photo Library.
  ///
  static func asset_delete(for mediaType: PHAssetMediaType, with assetIdentifier: String) async throws {
    guard let asset: PHAsset = await assetFromIdentifier(assetIdentifier, for: mediaType) else {
      throw CommonError.assetNotFound(assetIdentifier)
    }

    try await PHPhotoLibrary.shared().performChanges {
      PHAssetChangeRequest.deleteAssets([asset] as NSFastEnumeration)
    }
    KYPhotoLibraryLog("Delete asset succeeded.")
  }
}
