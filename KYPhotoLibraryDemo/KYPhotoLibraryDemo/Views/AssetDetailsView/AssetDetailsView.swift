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
        self.viewModel.processing == .cache ||
        self.viewModel.processing == .deleteCache ||
        self.viewModel.processing == .deleteCache
      {
        Color.black.opacity(0.8).ignoresSafeArea()
        _processingView()
      }
    }
    .toolbar {
      ToolbarItemGroup(placement: .topBarTrailing) {
        if self.viewModel.type == .video && self.viewModel.processing != .load {
          Menu {
            Button(action: self.viewModel.cacheAsset) { _navigationBarMenuOptionLabel(for: .cache) }
            Divider()
            Button(role: .destructive, action: self.viewModel.deleteCachedAsset) { _navigationBarMenuOptionLabel(for: .deleteCache) }
            Button(role: .destructive, action: self.viewModel.deleteAssetFromPhotoLibrary) { _navigationBarMenuOptionLabel(for: .deleteFile) }
          } label: {
            Image(systemName: "ellipsis")
          }
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
      .onAppear(perform: self.viewModel.startAssetLoading)
      .onDisappear(perform: self.viewModel.terminateAssetLoading)
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

      Button(action: self.viewModel.terminateCurrentProcessing) {
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
