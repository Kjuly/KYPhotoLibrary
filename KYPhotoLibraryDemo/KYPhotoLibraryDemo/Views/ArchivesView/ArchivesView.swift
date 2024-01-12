//
//  ArchivesView.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 8/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI

struct ArchivesView: View {

  private let type: DemoAssetType = .archive

  @StateObject private var viewModel = ArchivesViewModel()
  @State private var selectedAssetIdentifier: String?
  @State private var isPresentingDeletionDialog: Bool = false

  // MARK: - View Body

  var body: some View {
    ZStack {
      Color(uiColor: .systemGroupedBackground)
        .ignoresSafeArea()

      _archivesView()
    }
    .navigationTitle("KYPhotoLibrary Demo")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      self.viewModel.loadCachedFiles()
    }
    .toolbar {
      ToolbarItemGroup(placement: .confirmationAction) {
        if !self.viewModel.assetFilenames.isEmpty {
          Button(role: .destructive) {
            self.isPresentingDeletionDialog = true
          } label: {
            Image(systemName: "trash")
              .foregroundColor(self.viewModel.isDeletingAssets ? .secondary : .red)
          }
          .disabled(self.viewModel.isDeletingAssets)
          .confirmationDialog("", isPresented: $isPresentingDeletionDialog, titleVisibility: .hidden) {
            Button("Clean All", role: .destructive) {
              self.viewModel.isDeletingAssets = true
            }
            Button("Cancel", role: .cancel) {
              self.isPresentingDeletionDialog = false
            }
          } message: {
            Text("Would you like to clean all cached files?")
          }
        }
      }
    }
  }

  // MARK: - Private

  @ViewBuilder
  private func _archivesView() -> some View {
    if self.viewModel.isLoading {
      List {
        Section("Cached Files") {
          Text("Filename A")
          Text("Filename B")
          Text("Filename C")
        }
      }
      .redacted(reason: .placeholder)

    } else if self.viewModel.isDeletingAssets {
      Text("Deleting...").font(.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.viewModel.deleteAllCachedFiles()
          }
        })

    } else if self.viewModel.assetFilenames.isEmpty {
      VStack(alignment: .center) {
        Text(self.type.noMediaText)
          .font(.title)
          .foregroundColor(.secondary)
      }
      .frame(maxHeight: .infinity)

    } else {
      _assetFilenamesList()
    }
  }

  @ViewBuilder
  private func _assetFilenamesList() -> some View {
    List {
      Section("Cached Files") {
        ForEach(self.viewModel.assetFilenames, id: \.self) { filename in
          NavigationLink(
            destination: AssetDetailsView(
              selectedAssetIdentifier: $selectedAssetIdentifier,
              viewModel: .init(for: self.type, with: filename)),
            tag: filename,
            selection: $selectedAssetIdentifier
          ) {
            Text(filename)
          }
        }
      }
    }
  }
}
