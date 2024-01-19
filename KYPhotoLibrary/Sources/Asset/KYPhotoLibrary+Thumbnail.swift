//
//  KYPhotoLibrary+Thumbnail.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 19/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import UIKit
import Photos

extension KYPhotoLibrary {

  /// Load the thumbnail of an MPMediaItem object.
  ///
  /// - Parameters:
  ///   - asset: A PHAsset object representing the asset in Photo Library.
  ///   - boundingSize: Maximum thumbnail size.
  ///
  /// - Returns: A UIImage object representing a thumbnail.
  ///
  public static func loadThumbnail(
    for asset: PHAsset,
    boundingSize: CGSize = KYPhotoLibraryThumbnailDefaults.maxSize
  ) async throws -> UIImage {

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
  /// - Returns: A UIImage object representing a thumbnail.
  ///
  public static func loadThumbnail(
    with fileURL: URL,
    boundingSize: CGSize = KYPhotoLibraryThumbnailDefaults.maxSize
  ) async throws -> UIImage {

    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      throw KYPhotoLibrary.AssetError.fileNotFound(fileURL)
    }

    guard let fileType = UTType.ky_fromFile(with: fileURL) else {
      throw KYPhotoLibrary.AssetError.unknownFileType
    }

    if fileType.ky_isPhotoFileType() {
      if let posterImage = UIImage(contentsOfFile: fileURL.path) {
        return getThumbnail(from: posterImage, boundingSize: boundingSize)
      } else {
        throw KYPhotoLibrary.AssetError.fileNotFound(fileURL)
      }

    } else {
      let asset = AVAsset(url: fileURL)
      let image: UIImage = try await generateImage(from: asset, timestamp: 0, scale: 1)
      return getThumbnail(from: image, boundingSize: boundingSize)
    }
  }

  /// Generate an image from an asset at a specific timestamp.
  ///
  /// - Parameters:
  ///   - asset: An AVAsset object to generate the image.
  ///   - timestamp: The specific timestamp of the asset.
  ///   - scale: Image scale ratio.
  ///
  /// - Returns: An image.
  ///
  public static func generateImage(
    from asset: AVAsset,
    timestamp: TimeInterval,
    scale: CGFloat
  ) async throws -> UIImage {
    let assetImageGenerator = AVAssetImageGenerator(asset: asset)
    let imageRef: CGImage = try assetImageGenerator.copyCGImage(at: timestamp.ky_toCMTime, actualTime: nil)
    let image = UIImage(cgImage: imageRef, scale: scale, orientation: .up)
    return image
  }

  // MARK: - Private

  /// Resize the image to obtain the thumbnail internal bounding size.
  ///
  /// - Parameters:
  ///   - image: The original image.
  ///   - boundingSize: Maximum thumbnail size.
  ///
  /// - Returns: A UIImage object representing a thumbnail.
  ///
  public static func getThumbnail(
    from image: UIImage,
    boundingSize: CGSize = KYPhotoLibraryThumbnailDefaults.maxSize
  ) -> UIImage {

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
