//
//  KYPhotoLibrary+Image.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 30/6/2016.
//  Copyright © 2016 Kaijie Yu. All rights reserved.
//

import UIKit
import Photos

extension KYPhotoLibrary {

  // MARK: - Public - Save Image to Photo Library

  /// Save an image to custom album.
  ///
  /// - Parameters:
  ///   - image: The image to save.
  ///   - albumName: Custom album name.
  ///   - completion: The block to execute on completion.
  ///
  /// - Returns: Saved image's localIdentifier; nil if failed to save.
  ///
  public static func saveImage(_ image: UIImage, toAlbum albumName: String) async throws -> String {
    return try await asset_save(image: image, imageURL: nil, videoURL: nil, toAlbum: albumName)
  }

  // MARK: - Public - Delete Image from Photo Library

  public static func deleteImage(with assetIdentifier: String) async throws {
    try await asset_delete(for: .image, with: assetIdentifier)
  }

  // MARK: - Public - Load Image from Photo Library

  /// Load an image with a specific asset local identifier.
  ///
  /// - Parameters:
  ///   - assetIdentifier: The asset's unique identifier used in the Photo Library.
  ///   - expectedSize: The expected size of the image to be returned, default: zero.
  ///   - deliveryMode: The requested image quality and delivery priority, default: highQualityFormat.
  ///   - resizeMode: The mode that specifies how to resize the requested image, default: exact.
  ///   - completion: The block to execute on completion.
  ///
  /// - Returns: A matched image, nil if not found.
  ///
  public static func loadImage(
    with assetIdentifier: String,
    expectedSize: CGSize = .zero,
    deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat,
    resizeMode: PHImageRequestOptionsResizeMode = .exact
  ) async throws -> UIImage {

    guard let asset: PHAsset = await assetFromIdentifier(assetIdentifier, for: .image) else {
      throw CommonError.assetNotFound(assetIdentifier)
    }
    try Task.checkCancellation()

    let options = PHImageRequestOptions()
    options.deliveryMode = deliveryMode
    options.resizeMode = resizeMode
    return try await _loadImage(asset, expectedSize: expectedSize, options: options)
  }

  /// Load multiple images from an album.
  ///
  /// - Parameters:
  ///   - albumName: Custom album name.
  ///   - expectedSize: The expected size of the image to be returned, default: zero.
  ///   - deliveryMode: The requested image quality and delivery priority, default: highQualityFormat.
  ///   - resizeMode: The mode that specifies how to resize the requested image, default: exact.
  ///   - limit: The maximum number of images to fetch at one time.
  ///   - terminateOnError: Whether to terminate whenever an error occurs with an image, default: false.
  ///   - completion: The block to execute on completion.
  ///
  /// - Returns: An array of matched image, or an empty array if no images match the request.
  ///
  public static func loadImages(
    fromAlbum albumName: String,
    expectedSize: CGSize = .zero,
    deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat,
    resizeMode: PHImageRequestOptionsResizeMode = .exact,
    limit: Int,
    terminateOnError: Bool = false
  ) async throws -> [UIImage] {

    if albumName.isEmpty {
      throw CommonError.invalidAlbumName(albumName)
    }

    let assets: PHFetchResult<PHAsset> = try await loadAssets(of: .image, fromAlbum: albumName, limit: limit)
    guard assets.firstObject != nil else {
      return []
    }

    try Task.checkCancellation()

    let options = PHImageRequestOptions()
    options.deliveryMode = deliveryMode
    options.resizeMode = resizeMode

    return try await withThrowingTaskGroup(of: UIImage.self, returning: [UIImage].self) { taskGroup in
      for i in 0..<assets.count {
        let isTaskAdded = taskGroup.addTaskUnlessCancelled {
          try await _loadImage(assets.object(at: i), expectedSize: expectedSize, options: options)
        }
        if !isTaskAdded {
          break
        }
      }

      if terminateOnError {
        var images: [UIImage] = []
        // Fails the task group if a child task throws an error.
        while let loadedImage = try await taskGroup.next() {
          images.append(loadedImage)
        }
        return images

      } else {
        // var images = [UIImage]()
        // for await result in taskGroup { images.append(result) }
        // return images
        return try await taskGroup.reduce(into: [UIImage]()) { partialResult, image in
          partialResult.append(image)
        }
      }
    }
  }

  // MARK: - Private - Load Image from Photo Library

  private static func _loadImage(_ asset: PHAsset, expectedSize: CGSize, options: PHImageRequestOptions) async throws -> UIImage {
    let assetRequestActor = AssetRequestActor()

    return try await withTaskCancellationHandler {
      KYPhotoLibraryLog("Start Image Request...")
      return try await assetRequestActor.requestImage(asset, expectedSize: expectedSize, options: options)
    } onCancel: {
      Task {
        KYPhotoLibraryLog("Cancel Image Request...")
        await assetRequestActor.cancelRequst()
      }
    }
  }
}
