//
//  KYPhotoLibrary+Thumbnail.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 19/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation

#if os(iOS)
import Photos
import UIKit

extension KYPhotoLibrary {

  /// Load the thumbnail of a PHAsset object.
  ///
  /// - Parameters:
  ///   - asset: A PHAsset object representing the asset in Photo Library.
  ///   - boundingSize: Maximum thumbnail size.
  ///
  /// - Returns: A thumbnail image.
  ///
  public static func loadThumbnail(
    for asset: PHAsset,
    boundingSize: CGSize = KYPhotoLibraryThumbnailDefaults.maxSize
  ) async throws -> KYPhotoLibraryImage {

    let options = PHImageRequestOptions()
    options.isSynchronous = true
    options.isNetworkAccessAllowed = true

    let assetRequestActor = AssetRequestActor()

    return try await withTaskCancellationHandler {
      KYPhotoLibraryLog("Start thumbnail image request...")
      return try await assetRequestActor.requestImage(asset, expectedSize: boundingSize, options: options)
    } onCancel: {
      Task {
        KYPhotoLibraryLog("Cancel thumbnail image request...")
        await assetRequestActor.cancelRequst()
      }
    }
  }

  /// Loads a thumbnail image of the asset at a URL.
  ///
  /// - Parameters:
  ///   - fileURL: The URL of the asset.
  ///   - boundingSize: Maximum thumbnail size.
  ///
  /// - Returns: A thumbnail image.
  ///
  public static func loadThumbnail(
    with fileURL: URL,
    boundingSize: CGSize = KYPhotoLibraryThumbnailDefaults.maxSize
  ) async throws -> KYPhotoLibraryImage {

    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      throw KYPhotoLibrary.AssetError.fileNotFound(fileURL)
    }

    guard let fileType = UTType.ky_fromFile(with: fileURL) else {
      throw KYPhotoLibrary.AssetError.unknownFileType
    }

    if fileType.ky_isPhotoFileType() {
      if let posterImage = KYPhotoLibraryImage(contentsOfFile: fileURL.path) {
        return getThumbnail(from: posterImage, boundingSize: boundingSize)
      } else {
        throw KYPhotoLibrary.AssetError.fileNotFound(fileURL)
      }

    } else {
      let asset = AVAsset(url: fileURL)
      let image: KYPhotoLibraryImage = try await generateImage(from: asset, timestamp: 0)
      return getThumbnail(from: image, boundingSize: boundingSize)
    }
  }

  /// Generate an image from an asset at a specific timestamp.
  ///
  /// - Parameters:
  ///   - asset: An AVAsset object to generate the image.
  ///   - timestamp: The specific timestamp of the asset.
  ///
  /// - Returns: An image.
  ///
  public static func generateImage(
    from asset: AVAsset,
    timestamp: TimeInterval
  ) async throws -> KYPhotoLibraryImage {
    let assetImageGenerator = AVAssetImageGenerator(asset: asset)
    let imageRef: CGImage = try assetImageGenerator.copyCGImage(at: timestamp.ky_toCMTime, actualTime: nil)
#if os(macOS)
    let image = KYPhotoLibraryImage(cgImage: imageRef, size: .zero)
#else
    let image = KYPhotoLibraryImage(cgImage: imageRef, scale: 1, orientation: .up)
#endif
    return image
  }

  // MARK: - Private

  /// Resize the image to obtain the thumbnail internal bounding size.
  ///
  /// - Parameters:
  ///   - image: The original image.
  ///   - boundingSize: Maximum thumbnail size.
  ///
  /// - Returns: A thumbnail image.
  ///
  public static func getThumbnail(
    from image: KYPhotoLibraryImage,
    boundingSize: CGSize = KYPhotoLibraryThumbnailDefaults.maxSize
  ) -> KYPhotoLibraryImage {

    let imageSize = image.size
    let thumbnailSize = CGSize(width: boundingSize.width, height: boundingSize.width * imageSize.height / imageSize.width)

    if thumbnailSize.width >= imageSize.width && thumbnailSize.height >= imageSize.height {
      return image

    } else {
      // UIGraphicsImageRenderer *imageRenderer = [[UIGraphicsImageRenderer alloc] initWithSize:size]
      // thumbnail = [imageRenderer imageWithActions:^(UIGraphicsImageRendererContext *rendererContext) {}]
      UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 0)
      image.draw(in: CGRect(origin: .zero, size: thumbnailSize))
      let thumbnail: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return thumbnail ?? image
    }
  }
}
#endif
