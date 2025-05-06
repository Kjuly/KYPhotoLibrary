//
//  KYPhotoLibrary+Image.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 30/6/2016.
//  Copyright © 2016 Kaijie Yu. All rights reserved.
//

import Foundation
import Photos

#if os(iOS)
import UIKit
public typealias KYPhotoLibraryImage = UIImage
#else
import AppKit
public typealias KYPhotoLibraryImage = NSImage
extension NSImage: @unchecked Sendable {}
#endif

extension KYPhotoLibrary {

  // MARK: - Public - Save Image to Photo Library

  /// Save an image to custom album.
  ///
  /// - Parameters:
  ///   - image: The image to save.
  ///   - albumName: Custom album name.
  ///
  /// - Returns: Saved image's localIdentifier.
  ///
  public static func saveImage(_ image: KYPhotoLibraryImage, toAlbum albumName: String?) async throws -> String {
    return try await asset_save(image: image, imageURL: nil, videoURL: nil, toAlbum: albumName)
  }

  /// Save an image with a URL to custom album.
  ///
  /// - Parameters:
  ///   - imageURL: The URL of the image to save.
  ///   - albumName: Custom album name.
  ///
  /// - Returns: Saved image's localIdentifier.
  ///
  public static func saveImage(with imageURL: URL, toAlbum albumName: String?) async throws -> String {
    return try await asset_save(image: nil, imageURL: imageURL, videoURL: nil, toAlbum: albumName)
  }

  // MARK: - Public - Delete Image from Photo Library

  /// Delete an image with a specific asset local identifier from Photo Library.
  ///
  /// - Parameters:
  ///   - assetIdentifier: The asset's unique identifier used in the Photo Library.
  ///
  public static func deleteImage(with assetIdentifier: String) async throws {
    try await asset_delete(for: .image, with: assetIdentifier)
  }

  // MARK: - Public - Load Image from Photo Library

  /// Load an image with a specific asset local identifier.
  ///
  /// - Parameters:
  ///   - assetIdentifier: The asset's unique identifier used in the Photo Library.
  ///   - expectedSize: The expected size of the image to be returned, default: zero (original size).
  ///   - deliveryMode: The requested image quality and delivery priority, default: highQualityFormat.
  ///   - resizeMode: The mode that specifies how to resize the requested image, default: exact.
  ///
  /// - Returns: A matched image, nil if not found.
  ///
  public static func loadImage(
    with assetIdentifier: String,
    expectedSize: CGSize = .zero,
    deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat,
    resizeMode: PHImageRequestOptionsResizeMode = .exact
  ) async throws -> KYPhotoLibraryImage {

    guard let asset: PHAsset = await asset(with: assetIdentifier, for: .image) else {
      throw AssetError.assetNotFound(assetIdentifier)
    }

    let options = PHImageRequestOptions()
    options.deliveryMode = deliveryMode
    options.resizeMode = resizeMode
    return try await _loadImageForAsset(asset, expectedSize: expectedSize, options: options)
  }

  /// Load an image with a specific asset local identifier.
  ///
  /// - Parameters:
  ///   - assetIdentifier: The asset's unique identifier used in the Photo Library.
  ///   - expectedSize: The expected size of the image to be returned, default: zero (original size).
  ///   - requestOptions: Options specifying how Photos should handle the request, format the requested image,
  ///     and notify your app of progress or errors.
  ///
  /// - Returns: A matched image, nil if not found.
  ///
  public static func loadImage(
    with assetIdentifier: String,
    expectedSize: CGSize = .zero,
    requestOptions: PHImageRequestOptions?
  ) async throws -> KYPhotoLibraryImage {

    guard let asset: PHAsset = await asset(with: assetIdentifier, for: .image) else {
      throw AssetError.assetNotFound(assetIdentifier)
    }
    return try await _loadImageForAsset(asset, expectedSize: expectedSize, options: requestOptions)
  }

  /// Load multiple images from an album.
  ///
  /// - Parameters:
  ///   - albumName: Custom album name.
  ///   - expectedSize: The expected size of the image to be returned, default: zero (original size).
  ///   - deliveryMode: The requested image quality and delivery priority, default: highQualityFormat.
  ///   - resizeMode: The mode that specifies how to resize the requested image, default: exact.
  ///   - limit: The maximum number of images to fetch at one time.
  ///   - terminateOnError: Whether to terminate whenever an error occurs with an image, default: false.
  ///
  /// - Returns: An array of matched image, or an empty array if no images match the request.
  ///
  public static func loadImages(
    fromAlbum albumName: String?,
    expectedSize: CGSize = .zero,
    deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat,
    resizeMode: PHImageRequestOptionsResizeMode = .exact,
    limit: Int,
    terminateOnError: Bool = false
  ) async throws -> [KYPhotoLibraryImage] {

    let assets: PHFetchResult<PHAsset> = try await loadAssets(of: .image, fromAlbum: albumName, limit: limit)
    guard assets.firstObject != nil else {
      return []
    }

    try Task.checkCancellation()

    let options = PHImageRequestOptions()
    options.deliveryMode = deliveryMode
    options.resizeMode = resizeMode

    return try await withThrowingTaskGroup(of: KYPhotoLibraryImage.self, returning: [KYPhotoLibraryImage].self) { taskGroup in
      for i in 0..<assets.count {
        let isTaskAdded = taskGroup.addTaskUnlessCancelled {
          try await _loadImageForAsset(assets.object(at: i), expectedSize: expectedSize, options: options)
        }
        if !isTaskAdded {
          break
        }
      }

      if terminateOnError {
        var images: [KYPhotoLibraryImage] = []
        // Fails the task group if a child task throws an error.
        while let loadedImage = try await taskGroup.next() {
          images.append(loadedImage)
        }
        return images

      } else {
        // var images = [UIImage]()
        // for await result in taskGroup { images.append(result) }
        // return images
        return try await taskGroup.reduce(into: [KYPhotoLibraryImage]()) { partialResult, image in
          partialResult.append(image)
        }
      }
    }
  }

  // MARK: - Private - Load Image from Photo Library

  /// **[PKG Internal Usage Only]** Load an image for a specific asset..
  ///
  /// - Parameters:
  ///   - asset: The asset's unique identifier used in the Photo Library.
  ///   - expectedSize: The expected size of the image to be returned, default: zero (original size).
  ///   - requestOptions: Options specifying how Photos should handle the request, format the requested image,
  ///     and notify your app of progress or errors.
  ///
  /// - Returns: A matched image.
  ///
  private static func _loadImageForAsset(
    _ asset: PHAsset,
    expectedSize: CGSize,
    options: PHImageRequestOptions?
  ) async throws -> KYPhotoLibraryImage {

    let assetRequestActor = AssetRequestActor()

    return try await withTaskCancellationHandler {
      KYPhotoLibraryLog("Start Image Request...")
      return try await assetRequestActor.requestImage(
        asset,
        targetSize: expectedSize,
        contentMode: .aspectFit,
        options: options)

    } onCancel: {
      Task {
        KYPhotoLibraryLog("Cancel Image Request...")
        await assetRequestActor.cancelRequst()
      }
    }
  }
}
