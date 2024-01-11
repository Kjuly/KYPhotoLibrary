//
//  KYPhotoLibrary+AssetCreation.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 11/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import UIKit
import Photos

extension KYPhotoLibrary {

  /// **[PKG Internal Usage Only]** Save an image or video to custom album.
  ///
  /// - Parameters:
  ///   - image: The image to save.
  ///   - videoURL: The URL of the video to save.
  ///   - albumName: Custom album name.
  ///   - completion: The block to execute on completion.
  ///
  /// - Returns: Saved asset's localIdentifier.
  ///
  static func asset_save(image: UIImage?, videoURL: URL?, toAlbum albumName: String) async throws -> String {
    if image == nil && videoURL == nil {
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
}
