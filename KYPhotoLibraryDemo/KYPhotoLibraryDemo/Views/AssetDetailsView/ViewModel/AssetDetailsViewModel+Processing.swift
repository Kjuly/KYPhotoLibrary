//
//  AssetDetailsViewModel+Processing.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 11/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import UIKit
import KYPhotoLibrary

extension AssetDetailsViewModel {
  
  // MARK: - Cache Asset

  @MainActor
  func cacheAsset() {
    guard
      self.type == .video,
      self.assetCachingTask == nil
    else {
      return
    }
    self.processing = .cacheFile

    let exportOptions = KYPhotoLibraryVideoExportOptions(
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

    if let image = self.loadedAsset as? UIImage {
      _ = try await KYPhotoLibrary.saveImage(image, toAlbum: KYPhotoLibraryDemoApp.customPhotoAlbumName)
    } else {
      _ = try await KYPhotoLibrary.saveVideo(with: fileURL, toAlbum: KYPhotoLibraryDemoApp.customPhotoAlbumName)
    }
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
