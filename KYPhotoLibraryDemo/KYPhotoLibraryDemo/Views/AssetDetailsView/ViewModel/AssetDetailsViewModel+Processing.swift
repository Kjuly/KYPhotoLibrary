//
//  AssetDetailsViewModel+Processing.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 11/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import UIKit
import Photos
import KYPhotoLibrary

extension AssetDetailsViewModel {

  // MARK: - Cache Asset

  @MainActor
  func cacheImage(original: Bool) {
    self.processing = .cacheFile

    let exportOptions = KYPhotoLibraryAssetExportOptions(
      folderURL: KYPhotoLibraryDemoApp.archivesFolderURL,
      filename: nil,
      shouldRemoveDuplicates: false)

    self.assetCachingTask = Task {
      defer {
        self.assetCachingTask = nil
      }

      do {
        var outputURL: URL?

        if original {
          outputURL = try await KYPhotoLibrary.exportImageFromPhotoLibrary(
            with: self.assetIdentifier,
            requestOptions: nil,
            exportOptions: exportOptions)

        } else if let image = self.loadedAsset as? UIImage {
          outputURL = try await KYPhotoLibrary.exportImage(
            image,
            exportOptions: exportOptions)
        }

        if let outputURL {
          NSLog("Cached asset at \(outputURL)")
        } else {
          NSLog("Failed to Cached asset")
        }

      } catch {
        NSLog("Failed to Cached asset, error: \(error.localizedDescription)")
      }

      await MainActor.run {
        self.processing = .none
      }
    }
  }

  @MainActor
  func cacheVideo() {
    guard self.assetCachingTask == nil else {
      return
    }
    self.processing = .cacheFile

    let exportOptions = KYPhotoLibraryAssetExportOptions(
      folderURL: KYPhotoLibraryDemoApp.archivesFolderURL,
      filename: nil,
      shouldRemoveDuplicates: false)

    self.assetCachingTask = Task {
      defer {
        self.assetCachingTask = nil
      }

      do {
        let cachedAssetURL: URL? =
        try await KYPhotoLibrary.exportVideoFromPhotoLibrary(
          with: self.assetIdentifier,
          requestOptions: nil,
          exportOptions: exportOptions)

        if let cachedAssetURL {
          NSLog("Cached asset at \(cachedAssetURL)")
        } else {
          NSLog("Failed to Cached asset")
        }

      } catch {
        NSLog("Failed to Cached asset, error: \(error.localizedDescription)")
      }

      await MainActor.run {
        self.processing = .none
      }
    }
  }

  // MARK: - Delete Cached Asset

  @MainActor
  func deleteCachedAsset() throws {
    guard self.type == .archive else {
      return
    }

    let fileURL: URL = self.cachedAssetFileURL
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      return
    }
    try FileManager.default.removeItem(at: fileURL)
    NSLog("Deleted cached file \(self.assetIdentifier).")
  }

  // MARK: - Save Asset to Photo Library's Album

  func saveAssetToAlbum() async throws {
    guard self.type == .archive else {
      return
    }

    let fileURL: URL = self.cachedAssetFileURL
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      return
    }

    var mediaType: PHAssetMediaType
    if self.loadedAsset is UIImage {
      mediaType = .image
    } else {
      mediaType = .video
    }
    // Save asset to Photo Library album.
    //
    // Alternatively, you can use `static KYPhotoLibrary.saveImage(with:toAlbum:)`
    //   and `static KYPhotoLibrary.saveVideo(with:toAlbum:)`.
    //
    _ = try await KYPhotoLibrary.saveAsset(for: mediaType, with: fileURL, toAlbum: KYPhotoLibraryDemoApp.customPhotoAlbumName)
  }

  // MARK: - Delete Asset from Photo Library

  func deleteAssetFromPhotoLibrary() async throws {
    if self.type == .photo {
      try await KYPhotoLibrary.deleteImage(with: self.assetIdentifier)
    } else if self.type == .video {
      try await KYPhotoLibrary.deleteVideo(with: self.assetIdentifier)
    }
  }

  // MARK: - Terminate Processing

  @MainActor
  func terminateCurrentProcessing() {
    if self.assetCachingTask != nil {
      self.assetCachingTask?.cancel()
      self.assetCachingTask = nil
    }

    if self.processing == .cacheFile {
      self.processing = .none
    }
  }
}
