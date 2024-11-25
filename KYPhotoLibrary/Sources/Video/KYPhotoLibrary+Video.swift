//
//  KYPhotoLibrary+Video.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import Photos
import AVFoundation

extension KYPhotoLibrary {

  // MARK: - Public - Save Video to Photo Library

  /// Save a video to custom album.
  ///
  /// - Parameters:
  ///   - videoURL: The URL of the video to save.
  ///   - albumName: Custom album name.
  ///
  /// - Returns: Saved video's localIdentifier.
  ///
  public static func saveVideo(with videoURL: URL, toAlbum albumName: String) async throws -> String {
    return try await asset_save(image: nil, imageURL: nil, videoURL: videoURL, toAlbum: albumName)
  }

  // MARK: - Public - Delete Video from Photo Library

  /// Delete a video with a specific asset local identifier from Photo Library.
  ///
  /// - Parameters:
  ///   - assetIdentifier: The asset's unique identifier used in the Photo Library.
  ///
  public static func deleteVideo(with assetIdentifier: String) async throws {
    try await asset_delete(for: .video, with: assetIdentifier)
  }

  // MARK: - Public - Load Video from Photo Library

  /// Load a video with a specific asset local identifier.
  ///
  /// - Parameters:
  ///   - assetIdentifier: The asset's unique identifier used in the Photo Library.
  ///   - options: Options specifying how Photos should handle the request and notify your app of progress or errors.
  ///
  /// - Returns: An AVAsset object that provides access to the video asset as a collection of tracks and metadata.
  ///
  public static func loadVideo(
    with assetIdentifier: String,
    options: PHVideoRequestOptions? = nil
  ) async throws -> AVAsset {

    guard let asset: PHAsset = await asset(with: assetIdentifier, for: .video) else {
      throw AssetError.assetNotFound(assetIdentifier)
    }
    return try await _loadVideoForAsset(asset, options: options)
  }

  // MARK: - Private - Load Video from Photo Library

  private static func _loadVideoForAsset(_ asset: PHAsset, options: PHVideoRequestOptions?) async throws -> AVAsset {
    let assetRequestActor = AssetRequestActor()

    return try await withTaskCancellationHandler {
      KYPhotoLibraryLog("Start Video Request...")
      return try await assetRequestActor.requestVideo(asset, options: options)
    } onCancel: {
      Task {
        KYPhotoLibraryLog("Cancel Video Request...")
        await assetRequestActor.cancelRequst()
      }
    }
  }
}
