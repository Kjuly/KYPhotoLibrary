//
//  AssetDetailsViewModel.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import Photos
import AVFoundation
import KYPhotoLibrary

class AssetDetailsViewModel: ObservableObject {

  let type: DemoAssetType
  let assetIdentifier: String

  @Published var processing: DemoAssetProcessing = .load
  @Published var loadedAsset: AnyObject?

  private var assetCachingTask: Task<Void, Error>?

  @Published var error: AssetDetailsViewModelError?

  // MARK: - Init

  init(for type: DemoAssetType, with assetIdentifier: String) {
    self.type = type
    self.assetIdentifier = assetIdentifier
  }

  // MARK: - Asset Loading

  func startAssetLoading() async {
    var loadedAsset: AnyObject?

    if self.type == .archive {
      let fileURL: URL = KYPhotoLibraryDemoApp.archivesFolderURL.appendingPathComponent(self.assetIdentifier)
      if let fileType = UTType.ky_fromFile(with: fileURL) {
        if fileType.ky_isPhotoFileType() {
          loadedAsset = UIImage(contentsOfFile: fileURL.path)
        } else if fileType.ky_isVideoFileType() {
          loadedAsset = AVURLAsset(url: fileURL)
        }
      }

    } else {
      do {
        if self.type == .photo {
          loadedAsset = try await KYPhotoLibrary.loadImage(with: self.assetIdentifier)
        } else {
          loadedAsset = try await KYPhotoLibrary.loadVideo(with: self.assetIdentifier)
        }
      } catch {
        NSLog("Failed to load asset, error: \(error.localizedDescription).")
      }
    }

    // Make sure to finish asset loading in main thread.
    //
    // Or just use the code snippet below:
    //
    //   await MainActor.run { [loadedAsset] in
    //     self.loadedAsset = loadedAsset
    //     self.processing = .none
    //   }
    //
    await _didFinishAssetLoading(with: loadedAsset)
  }

  @MainActor
  private func _didFinishAssetLoading(with loadedAsset: AnyObject?) async {
    self.loadedAsset = loadedAsset
    self.processing = .none
  }

  // MARK: - Processing

  @MainActor
  func cacheAsset() {
    guard
      self.type == .video,
      self.assetCachingTask == nil
    else {
      return
    }
    self.processing = .cache

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

  @MainActor
  func deleteCachedAsset() {

  }

  @MainActor
  func deleteAssetFromPhotoLibrary() {

  }

  // MARK: - Terminate Processing

  @MainActor
  func terminateCurrentProcessing() {
    if self.assetCachingTask != nil {
      self.assetCachingTask?.cancel()
      self.assetCachingTask = nil
    }

    if self.processing == .cache {
      self.processing = .none
    }
  }
}
