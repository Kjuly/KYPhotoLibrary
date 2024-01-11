//
//  AssetDetailsViewModel.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import Photos
import KYPhotoLibrary

class AssetDetailsViewModel: ObservableObject {

  let type: DemoAssetType
  let assetIdentifier: String

  @Published var processing: DemoAssetProcessing = .load
  @Published var loadedAsset: AnyObject?

  private var assetLoadingTask: Task<Void, Error>?
  private var assetCachingTask: Task<Void, Error>?

  @Published var error: AssetDetailsViewModelError?

  // MARK: - Init

  init(for type: DemoAssetType, with assetIdentifier: String) {
    self.type = type
    self.assetIdentifier = assetIdentifier
  }

  // MARK: - Asset Loading

  func startAssetLoading() {
    if self.type == .photo {
      self.assetLoadingTask = Task {
        _didFinishAssetLoading(with: try await KYPhotoLibrary.loadImage(with: self.assetIdentifier))
      }

    } else if self.type == .video {
      self.assetLoadingTask = Task {
        _didFinishAssetLoading(with: try await KYPhotoLibrary.loadVideo(with: self.assetIdentifier))
      }

    } else {
      let fileURL: URL = KYPhotoLibraryDemoApp.archivesFolderURL.appendingPathComponent(self.assetIdentifier)
      guard let fileType = UTType.ky_fromFile(with: fileURL) else {
        _didFinishAssetLoading(with: nil)
        return
      }

      if fileType.ky_isPhotoFileType() {
        _didFinishAssetLoading(with: UIImage(contentsOfFile: fileURL.path))
      } else if fileType.ky_isVideoFileType() {
        _didFinishAssetLoading(with: AVURLAsset(url: fileURL))
      } else {
        _didFinishAssetLoading(with: nil)
      }
    }
  }

  func terminateAssetLoading() {
    if self.assetLoadingTask != nil {
      self.assetLoadingTask?.cancel()
      self.assetLoadingTask = nil
    }

    if self.processing == .load {
      self.processing = .none
    }
  }

  private func _didFinishAssetLoading(with loadedAsset: AnyObject?) {
    self.loadedAsset = loadedAsset
    self.assetLoadingTask = nil
    self.processing = .none
  }

  // MARK: - Processing

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
        DispatchQueue.main.async {
          self.assetCachingTask = nil
          self.processing = .none
        }
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
    }
  }

  func deleteCachedAsset() {

  }

  func deleteAssetFromPhotoLibrary() {

  }

  // MARK: - Terminate Processing

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
