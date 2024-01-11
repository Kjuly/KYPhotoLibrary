//
//  AssetRequestActor.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 11/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import UIKit
import Photos

/// **[PKG Internal Usage Only]** Photo library asset request actor.
actor AssetRequestActor {

  var requestID: PHImageRequestID?

  /// Request image asset from Photo Library.
  func requestImage(_ asset: PHAsset, expectedSize: CGSize, options: PHImageRequestOptions) async throws -> UIImage {
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
          continuation.resume(throwing: KYPhotoLibrary.CommonError.failedToLoadAsset)
        }
      }
    }
  }

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
          continuation.resume(throwing: KYPhotoLibrary.CommonError.failedToLoadAsset)
        }
      }
    }
  }

  /// Cancel the asset request.
  func cancelRequst() async {
    guard let requestID = self.requestID else {
      return
    }
    PHImageManager.default().cancelImageRequest(requestID)
    self.requestID = nil
  }
}
