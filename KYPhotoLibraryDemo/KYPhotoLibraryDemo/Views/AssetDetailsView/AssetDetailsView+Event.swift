//
//  AssetDetailsView+Event.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 11/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation

extension AssetDetailsView {

  func event_cacheAsset() {
    self.viewModel.cacheAsset()
  }

  func event_deleteCachedAsset() {
    do {
      try self.viewModel.deleteCachedAsset()
      self.selectedAssetIdentifier = nil
    } catch {
      self.viewModel.error = AssetDetailsViewModelError.failedToDeleteCachedAsset(error.localizedDescription)
    }
  }

  func event_saveAssetToAlbum() {
    Task {
      do {
        try await self.viewModel.saveAssetToAlbum()
      } catch {
        self.viewModel.error = AssetDetailsViewModelError.failedTosaveAssetToAlbum(error.localizedDescription)
      }
    }
  }

  func event_deleteAssetFromPhotoLibrary() {
    Task {
      do {
        try await self.viewModel.deleteAssetFromPhotoLibrary()
        await MainActor.run {
          self.selectedAssetIdentifier = nil
        }
      } catch {
        await MainActor.run {
          self.viewModel.error = AssetDetailsViewModelError.failedToDeleteAssetFromPhotoLibrary(error.localizedDescription)
        }
      }
    }
  }
}