//
//  AssetRequestActor.swift
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

/// **[PKG Internal Usage Only]** Photo library asset request actor.
actor AssetRequestActor {

  var requestID: PHImageRequestID?
  var contentEditingInputRequestID: PHContentEditingInputRequestID?

  // MARK: - Image

  /// Request image asset from Photo Library.
  func requestImage(_ asset: PHAsset, expectedSize: CGSize, options: PHImageRequestOptions?) async throws -> KYPhotoLibraryImage {
    let targetSize = (CGSizeEqualToSize(expectedSize, .zero)
                      ? CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                      : expectedSize)

    return try await withCheckedThrowingContinuation { continuation in
      self.requestID = PHCachingImageManager.default().requestImage(
        for: asset,
        targetSize: targetSize,
        contentMode: .aspectFit,
        options: options
      ) { result, _ in
#if DEBUG
        KYPhotoLibraryDebug.simulateWaiting(.assetQuery)
#endif
        self.requestID = nil

        if let result {
          continuation.resume(returning: result)
        } else {
          continuation.resume(throwing: KYPhotoLibrary.AssetError.failedToLoadAsset)
        }
      }
    }
  }

  /// Request image URL from Photo Library.
  func requestImageURL(_ asset: PHAsset, options: PHContentEditingInputRequestOptions?) async throws -> URL {
    return try await withCheckedThrowingContinuation { continuation in
      self.contentEditingInputRequestID = asset.requestContentEditingInput(with: options) { contentEditingInput, _ in
        self.contentEditingInputRequestID = nil
        if
          let contentEditingInput,
          let imageURL: URL = contentEditingInput.fullSizeImageURL
        {
          continuation.resume(returning: imageURL)
        } else {
          continuation.resume(throwing: KYPhotoLibrary.AssetError.failedToGetAssetURL)
        }
      }
    }
  }

  // MARK: - Video

  /// Request video asset from Photo Library.
  func requestVideo(_ asset: PHAsset, options: PHVideoRequestOptions?) async throws -> AVAsset {
    return try await withCheckedThrowingContinuation { continuation in
      self.requestID = PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: options) { asset, _, _ in
#if DEBUG
        KYPhotoLibraryDebug.simulateWaiting(.assetQuery)
#endif
        self.requestID = nil

        if let asset {
          continuation.resume(returning: asset)
        } else {
          continuation.resume(throwing: KYPhotoLibrary.AssetError.failedToLoadAsset)
        }
      }
    }
  }

  /// Request video URL from Photo Library.
  func requestVideoURL(_ asset: PHAsset, options: PHVideoRequestOptions?) async throws -> URL {
    return try await withCheckedThrowingContinuation { continuation in
      self.requestID = PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: options) { asset, _, _ in
#if DEBUG
        KYPhotoLibraryDebug.simulateWaiting(.assetQuery)
#endif
        self.requestID = nil

        if let urlAsset = asset as? AVURLAsset {
          continuation.resume(returning: urlAsset.url)
        } else {
          continuation.resume(throwing: KYPhotoLibrary.AssetError.failedToGetAssetURL)
        }
      }
    }
  }

  // MARK: - Cancellation

  /// Cancel the asset request.
  func cancelRequst(_ asset: PHAsset? = nil) async {
    if let requestID = self.requestID {
      PHImageManager.default().cancelImageRequest(requestID)
      self.requestID = nil
    }

    if
      let requestID = self.contentEditingInputRequestID,
      let asset
    {
      asset.cancelContentEditingInputRequest(requestID)
      self.contentEditingInputRequestID = nil
    }
  }
}
