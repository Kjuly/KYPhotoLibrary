//
//  AssetsView.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 6/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import AVKit

struct AssetsView: View {

  private let type: DemoAssetType

  @StateObject private var viewModel = AssetsViewModel()
  @State private var selectedAssetIdentifier: String?
  @State private var isPresentingImagePicker: Bool = false

  // MARK: - Init

  init(for type: DemoAssetType) {
    self.type = type
  }

  // MARK: - View Body

  var body: some View {
    ZStack {
      Color(uiColor: .systemGroupedBackground)
        .ignoresSafeArea()

      _assetsView()
    }
    .navigationTitle("KYPhotoLibrary Demo")
    .navigationBarTitleDisplayMode(.inline)
    .safeAreaInset(edge: .bottom, alignment: .center, content: _pickMediaButton)
    .task {
      await self.viewModel.loadFilesFromCustomPhotoAlbum(for: self.type)
    }
    .fullScreenCover(isPresented: $isPresentingImagePicker) {
      DemoImagePicker(for: self.type) { image, videoURL in
        Task {
          await self.viewModel.didFinishPicking(with: image, or: videoURL)
        }
        self.isPresentingImagePicker = false
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
  private func _assetsView() -> some View {
    if self.viewModel.isLoading {
      List {
        Section(self.type.tabText) {
          Text("Filename A")
          Text("Filename B")
          Text("Filename C")
        }
      }
      .redacted(reason: .placeholder)

    } else if self.viewModel.assetItems.isEmpty {
      VStack(alignment: .center) {
        Text(self.type.noMediaText)
          .font(.title)
          .foregroundColor(.secondary)
      }
      .frame(maxHeight: .infinity)

    } else {
      _assetIdentifiersList()
    }
  }

  private func _assetIdentifiersList() -> some View {
    List {
      Section(self.type.tabText) {
        ForEach(self.viewModel.assetItems, id: \.identifier) { assetItem in
          NavigationLink(
            destination: AssetDetailsView(
              selectedAssetIdentifier: $selectedAssetIdentifier,
              viewModel: .init(for: self.type, with: assetItem.identifier)),
            tag: assetItem.identifier,
            selection: $selectedAssetIdentifier
          ) {
            _listCell(for: assetItem)
          }
        }
      }
    }
  }

  private func _listCell(for assetItem: AssetsListRowModel) -> some View {
    VStack(alignment: .leading) {
      Text(assetItem.filename)
      Text(assetItem.identifier)
        .font(.footnote)
        .foregroundColor(.secondary)
    }
  }

  private func _pickMediaButton() -> some View {
    Button(action: _pickMedia) {
      Text(self.type.pickMediaText)
        .font(.body.bold())
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
    .padding()
  }

  private func _pickMedia() {
    self.viewModel.reqeustCameraAuthorization { authorized in
      if authorized {
        self.isPresentingImagePicker = true
      }
    }
  }
}
