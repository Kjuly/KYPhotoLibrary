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
  ///   - boundingSize: Maximum thumbnail size; provide `.zero` to load the image at original size.
  ///   - scale: The scale factor to apply to the bitmap. If you specify a value of 0.0, the scale factor is set to the scale factor of the device’s main screen.
  ///   - aspectFill: An option for how to fit the image to the aspect ratio of the requested size.
  ///   - requestOptions: Options specifying how Photos should handle the request, format the requested image,
  ///     and notify your app of progress or errors.
  ///
  /// - Returns: A thumbnail image.
  ///
  public static func loadThumbnail(
    for asset: PHAsset,
    boundingSize: CGSize = KYPhotoLibraryThumbnailDefaults.maxSize,
    scale: CGFloat = 0,
    aspectFill: Bool = false
  ) async throws -> KYPhotoLibraryImage {

    let assetRequestActor = AssetRequestActor()

    return try await withTaskCancellationHandler {
      KYPhotoLibraryLog("Start thumbnail image request...")

      let imageScale: CGFloat = (scale > 0 ? scale : await UIScreen.main.scale)
      let targetSize = CGSizeMake(
        boundingSize.width  > 0 ? boundingSize.width  * imageScale : CGFloat(asset.pixelWidth),
        boundingSize.height > 0 ? boundingSize.height * imageScale : CGFloat(asset.pixelHeight)
      )

      let options = PHImageRequestOptions()
      options.isSynchronous = true
      options.isNetworkAccessAllowed = true

      return try await assetRequestActor.requestImage(
        asset,
        targetSize: targetSize,
        contentMode: aspectFill ? .aspectFill : .aspectFit,
        options: options)

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
  ///   - scale: The scale factor to apply to the bitmap. If you specify a value of 0.0, the scale factor is set to the scale factor of the device’s main screen.
  ///   - aspectFill: An option for how to fit the image to the aspect ratio of the requested size.
  ///
  /// - Returns: A thumbnail image.
  ///
  public static func loadThumbnail(
    with fileURL: URL,
    boundingSize: CGSize = KYPhotoLibraryThumbnailDefaults.maxSize,
    scale: CGFloat = 0,
    aspectFill: Bool = false
  ) async throws -> KYPhotoLibraryImage {

    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      throw KYPhotoLibrary.AssetError.fileNotFound(fileURL)
    }

    guard let fileType = UTType.ky_fromFile(with: fileURL) else {
      throw KYPhotoLibrary.AssetError.unknownFileType
    }

    if fileType.ky_isPhotoFileType() {
      if let posterImage = KYPhotoLibraryImage(contentsOfFile: fileURL.path) {
        return getThumbnail(from: posterImage, boundingSize: boundingSize, scale: scale, aspectFill: aspectFill)
      } else {
        throw KYPhotoLibrary.AssetError.fileNotFound(fileURL)
      }

    } else {
      let asset = AVAsset(url: fileURL)
      let image: KYPhotoLibraryImage = try await generateImage(from: asset, timestamp: 0)
      return getThumbnail(from: image, boundingSize: boundingSize, scale: scale, aspectFill: aspectFill)
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
    assetImageGenerator.appliesPreferredTrackTransform = true
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
  ///   - scale: The scale factor to apply to the bitmap. If you specify a value of 0.0, the scale factor is set to the scale factor of the device’s main screen.
  ///   - aspectFill: An option for how to fit the image to the aspect ratio of the requested size.
  ///
  /// - Returns: A thumbnail image.
  ///
  public static func getThumbnail(
    from image: KYPhotoLibraryImage,
    boundingSize: CGSize = KYPhotoLibraryThumbnailDefaults.maxSize,
    scale: CGFloat = 0,
    aspectFill: Bool = false
  ) -> KYPhotoLibraryImage {

    let imageSize = image.size
    let thumbnailSize = imageSize.ky_resize(aspectFill: aspectFill, boundingSize: boundingSize)

    if thumbnailSize.width >= imageSize.width && thumbnailSize.height >= imageSize.height {
      return image

    } else {
      // UIGraphicsImageRenderer *imageRenderer = [[UIGraphicsImageRenderer alloc] initWithSize:size]
      // thumbnail = [imageRenderer imageWithActions:^(UIGraphicsImageRendererContext *rendererContext) {}]
      UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, scale)
      image.draw(in: CGRect(origin: .zero, size: thumbnailSize))
      let thumbnail: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return thumbnail ?? image
    }
  }
}

// MARK: - CGSize Extension
extension CGSize {

  fileprivate func ky_resize(aspectFill: Bool, boundingSize: CGSize) -> CGSize {
    guard self.width > 0, self.height > 0 else {
      return self
    }

    let aspectRatio: CGFloat = self.width / self.height
    let boundingAspectRatio: CGFloat = boundingSize.width / boundingSize.height

    if
      ( aspectFill && aspectRatio < boundingAspectRatio) ||
      (!aspectFill && aspectRatio > boundingAspectRatio)
    {
      return CGSize(width: boundingSize.width, height: floor(boundingSize.width * self.height / self.width))
    } else {
      return CGSize(width: floor(boundingSize.height * aspectRatio), height: boundingSize.height)
    }
  }
}
#endif
