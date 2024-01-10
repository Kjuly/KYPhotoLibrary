//
//  ArchivesViewModel.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 8/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation

@MainActor
class ArchivesViewModel: ObservableObject {

  @Published var isLoading: Bool = true
  @Published var isDeletingAssets: Bool = false
  @Published var assetFilenames: [String] = []

  // MARK: - Action

  func loadCachedFiles() {
    let documentContents: [URL]? = try? FileManager.default.contentsOfDirectory(
      at: KYPhotoLibraryDemoApp.archivesFolderURL,
      includingPropertiesForKeys: [.nameKey],
      options: .skipsHiddenFiles)

    if let documentContents, !documentContents.isEmpty {
      self.assetFilenames = documentContents.map { $0.lastPathComponent }.sorted(by: <)
    } else {
      self.assetFilenames = []
    }
    self.isLoading = false
  }

  func deleteAllCachedFiles() {
    try? FileManager.default.removeItem(at: KYPhotoLibraryDemoApp.archivesFolderURL)
    self.assetFilenames = []
    self.isDeletingAssets = false
  }
}
