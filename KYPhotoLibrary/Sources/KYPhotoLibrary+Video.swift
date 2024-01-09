//
//  KYPhotoLibrary+Video.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import Photos

extension KYPhotoLibrary {

  // MARK: - Save/Load Video from Photo Library

  /// Save a video to custom album.
  ///
  /// If you need to update the UI in the completion block, you'd better to perform the relevant tasks in the main thread.
  ///
  /// - Parameters:
  ///   - videoURL: The URL of the video to save.
  ///   - albumName: Custom album name.
  ///   - completion: The block to execute on completion.
  ///
  public static func saveVideo(
    with videoURL: URL,
    toAlbum albumName: String,
    completion: AssetSavingCompletion?
  ) {
    assert(!albumName.isEmpty)

    let saveVideoToAlbum: AlbumCreationCompletion = { (assetCollection: PHAssetCollection?, albumCreationError: Error?) in
      guard let assetCollection else {
        if let completion {
          completion(nil, albumCreationError)
        }
        return
      }

      var assetPlaceholder: PHObjectPlaceholder?

      PHPhotoLibrary.shared().performChanges {
        let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        assetPlaceholder = createAssetRequest?.placeholderForCreatedAsset

        let collectionChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
        collectionChangeRequest?.addAssets([assetPlaceholder] as NSFastEnumeration)

      } completionHandler: { (success: Bool, performChangesError: Error?) in
#if DEBUG
        if success {
          KYPhotoLibraryLog("Add Video Succeeded: \(assetPlaceholder?.localIdentifier ?? "")")
        } else {
          KYPhotoLibraryLog("Add Video Failed: \(performChangesError?.localizedDescription ?? "")")
        }
#endif
        if let completion {
          completion(assetPlaceholder?.localIdentifier, performChangesError)
        }
      }
    }

    if let album: PHAssetCollection = getAlbum(with: albumName) {
      saveVideoToAlbum(album, nil)
    } else {
      createAlbum(with: albumName, completion: saveVideoToAlbum)
    }
  }

  /// Load a video with a specific asset local identifier.
  ///
  /// If you need to cancel the request before it completes, pass this identifier to the
  ///   static `KYPhotoLibrary.cancelAssetRequest(_:)` method, e.g.,
  /// ```swift
  /// let requestID: PHImageRequestID? = KYPhotoLibrary.loadVideo(...)
  /// KYPhotoLibrary.cancelAssetRequest(requestID)
  /// ```
  ///
  /// - Parameters:
  ///   - assetIdentifier: The asset's unique identifier used in the Photo Library.
  ///   - options: Options specifying how Photos should handle the request and notify your app of progress or errors.
  ///   - completion: The block to execute on completion.
  ///
  /// - Returns: A numeric identifier for the video request.
  ///
  public static func loadVideo(
    with assetIdentifier: String,
    options: PHVideoRequestOptions? = nil,
    completion: @escaping (_ videoAsset: AVAsset?) -> Void
  ) -> PHImageRequestID? {

    guard let asset: PHAsset = assetFromIdentifier(assetIdentifier, for: .video) else {
      completion(nil)
      return nil
    }

    return PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: options) { asset, _, _ in
      DispatchQueue.main.async {
        completion(asset)
      }
    }
  }
}
