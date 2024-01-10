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

  private var requestID: PHImageRequestID?
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
      self.requestID = KYPhotoLibrary.loadImage(with: self.assetIdentifier) { [weak self] image in
        self?._didFinishAssetLoading(with: image)
      }

    } else if self.type == .video {
      self.requestID = KYPhotoLibrary.loadVideo(with: self.assetIdentifier) { [weak self] videoAsset in
        self?._didFinishAssetLoading(with: videoAsset)
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
    KYPhotoLibrary.cancelAssetRequest(self.requestID)
  }

  private func _didFinishAssetLoading(with loadedAsset: AnyObject?) {
    self.loadedAsset = loadedAsset
    self.requestID = nil
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
