//
//  AssetDetailsView.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import AVKit

struct AssetDetailsView: View {

  @Binding var selectedAssetIdentifier: String?
  @ObservedObject var viewModel: AssetDetailsViewModel

  var body: some View {
    ZStack {
      Color(uiColor: .systemGroupedBackground)
        .ignoresSafeArea()

      if self.viewModel.processing == .load {
        _loadingView()
      } else if let image = self.viewModel.loadedAsset as? UIImage {
        photoView(with: image)
      } else if let videoAsset = self.viewModel.loadedAsset as? AVAsset {
        videoView(with: videoAsset)
      } else {
        _notFoundView()
      }

      if
        self.viewModel.processing == .cacheFile ||
        self.viewModel.processing == .deleteCachedFile ||
        self.viewModel.processing == .deleteFileFromPhotoLibrary
      {
        Color.black.opacity(0.8).ignoresSafeArea()
        _processingView()
      }
    }
    .toolbar {
      ToolbarItemGroup(placement: .topBarTrailing) {
        if self.viewModel.processing != .load {
          if self.viewModel.type == .archive { _archivesNavigationBarMoreMenu() }
          else { _photoLibraryAssetsNavigationBarMoreMenu() }
        }
      }
    }
    .alert(
      isPresented: .constant(self.viewModel.error != nil),
      error: self.viewModel.error,
      actions: { _ in
        Button("OK", role: .cancel) {
          self.viewModel.error = nil
        }
      },
      message: { localizedError in
        if let recoverySuggestion = localizedError.recoverySuggestion {
          Text(recoverySuggestion)
        }
      })
  }

  // MARK: - Private

  @ViewBuilder
  private func _loadingView() -> some View {
    Text(DemoAssetProcessing.load.inProcessingText)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .task {
        await self.viewModel.startAssetLoading()
      }
  }

  @ViewBuilder
  private func _archivesNavigationBarMoreMenu() -> some View {
    Menu {
      Button(action: event_saveAssetToAlbum) { _navigationBarMenuOptionLabel(for: .saveAssetToAlbum) }
      Divider()
      Button(role: .destructive, action: event_deleteCachedAsset) { _navigationBarMenuOptionLabel(for: .deleteCachedFile) }
    } label: {
      Image(systemName: "ellipsis")
    }
  }

  @ViewBuilder
  private func _photoLibraryAssetsNavigationBarMoreMenu() -> some View {
    Menu {
      Button(action: event_cacheAsset) { _navigationBarMenuOptionLabel(for: .cacheFile) }
      Divider()
      Button(role: .destructive, action: event_deleteAssetFromPhotoLibrary) { _navigationBarMenuOptionLabel(for: .deleteFileFromPhotoLibrary) }
    } label: {
      Image(systemName: "ellipsis")
    }
  }

  @ViewBuilder
  private func _navigationBarMenuOptionLabel(for processing: DemoAssetProcessing) -> some View {
    Label {
      Text(processing.actionText)
    } icon: {
      Image(systemName: processing.iconName)
    }
  }

  @ViewBuilder
  private func _processingView() -> some View {
    VStack(alignment: .center) {
      Text(self.viewModel.processing.inProcessingText)
        .font(.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity)

      Button {
        self.viewModel.terminateCurrentProcessing()
      } label: {
        Text("Terminate")
          .font(.body.bold())
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .tint(.red)
      .padding()
    }
  }

  @ViewBuilder
  private func _notFoundView() -> some View {
    Text(self.viewModel.type.mediaNotFoundText)
      .font(.title)
      .foregroundColor(.secondary)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
