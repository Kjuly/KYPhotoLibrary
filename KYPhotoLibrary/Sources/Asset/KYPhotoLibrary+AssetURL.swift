//
//  KYPhotoLibrary+AssetURL.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 21/5/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import Photos

extension KYPhotoLibrary {

  /// Get the asset URL with the Photo Library scheme "assets-library://".
  ///
  /// When "`scheme = .library`" (e.g., "assets-library://asset/asset.MP4?id=A45B74E5-003F-49CA-A7DB-FA978A29966C"),
  ///   `url.checkResourceIsReachable()` will return false because this is not a file system resource URL.
  ///   But we can still use `AVURLAsset(url:)` to load the asset.
  ///
  /// When "`scheme = .file`" (), will return a local file system resource URL using the file scheme "file://".
  ///   Its format is "file:///path/to/IMG_0001.MP4".
  ///
  /// - Parameters:
  ///   - assetIdentifier: The asset's unique identifier used in the Photo Library.
  ///   - mediaType: The expected media type of the asset.
  ///   - scheme: URL scheme, default: KYPhotoLibrary.URLScheme.library.
  ///   - useOriginalFilename: Whether use the original filename in the URL when the "`scheme = .library`",
  ///     default: false (will use "asset" as the file title); this option will be ignored when "`scheme = .file`".
  ///
  /// - Returns: An asset URL.
  ///
  public static func assetURL(
    with assetIdentifier: String,
    for mediaType: PHAssetMediaType,
    scheme: KYPhotoLibrary.URLScheme = .library,
    useOriginalFilename: Bool = false
  ) async throws -> URL {

    guard let asset: PHAsset = await assetFromIdentifier(assetIdentifier, for: mediaType) else {
      throw AssetError.assetNotFound(assetIdentifier)
    }

    if scheme == .file {
      if mediaType == .image {
        return try await _imageURL(of: asset)
      } else {
        return try await _videoURL(of: asset)
      }
    }

    // e.g.
    // -  assetLocalIdentifier: 809E4CCC-7AC3-4139-9512-0CD93FFEE2C5/L0/001
    // - uniformTypeIdentifier: public.mpeg-4 (kUTTypeMPEG4)
    // -      originalFilename: Title.MP4
    //
    guard let assetResource: PHAssetResource = assetResource(for: asset) else {
      throw AssetError.assetNotFound(assetIdentifier)
    }

    var filename: String
    if useOriginalFilename {
      filename = (assetResource.originalFilename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                  ?? assetResource.originalFilename)
    } else {
      guard let fileExtension: String = UTType.ky_getFileExtensionFromUniformTypeIdentifier(assetResource.uniformTypeIdentifier) else {
        throw AssetError.unsupportedMediaType(mediaType.rawValue)
      }
      filename = "asset.\(fileExtension)"
    }

    let identifier: String = assetIdentifier.components(separatedBy: "/").first ?? assetIdentifier
    let filePath: String = "assets-library://asset/\(filename)?id=\(identifier)"
    guard let url = URL(string: filePath) else {
      throw AssetError.invalidFilePath(filePath)
    }
    return url
  }

  // MARK: - Private

  private static func _imageURL(of asset: PHAsset) async throws -> URL {
    let assetRequestActor = AssetRequestActor()

    return try await withTaskCancellationHandler {
      KYPhotoLibraryLog("Start image URL request...")
      let options = PHContentEditingInputRequestOptions()
      options.canHandleAdjustmentData = { _ in true }
      return try await assetRequestActor.requestImageURL(asset, options: options)
    } onCancel: {
      Task {
        KYPhotoLibraryLog("Cancel image URL request...")
        await assetRequestActor.cancelRequst(asset)
      }
    }
  }

  private static func _videoURL(of asset: PHAsset) async throws -> URL {
    let assetRequestActor = AssetRequestActor()

    return try await withTaskCancellationHandler {
      KYPhotoLibraryLog("Start video URL request...")
      return try await assetRequestActor.requestVideoURL(asset, options: nil)
    } onCancel: {
      Task {
        KYPhotoLibraryLog("Cancel video URL request...")
        await assetRequestActor.cancelRequst()
      }
    }
  }
}
