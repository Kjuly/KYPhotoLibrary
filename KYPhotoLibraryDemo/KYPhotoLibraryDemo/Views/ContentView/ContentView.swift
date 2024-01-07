//
//  ContentView.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 6/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import AVKit

struct ContentView: View {

  let type: DemoMediaType

  @StateObject private var viewModel = ContentViewModel()
  @State private var isPresntingImagePicker = false

  init(for type: DemoMediaType) {
    self.type = type
  }

  var body: some View {
    ZStack {
      Color(uiColor: .systemGroupedBackground)
        .ignoresSafeArea()

      _contentView()
    }
    .navigationTitle("KYPhotoLibrary Demo")
    .navigationBarTitleDisplayMode(.inline)
    .safeAreaInset(edge: .bottom, alignment: .center, content: _pickMediaButton)
    .fullScreenCover(isPresented: $isPresntingImagePicker) {
      DemoImagePicker(for: self.type) { image, videoURL in
        self.viewModel.didFinishPicking(with: image, or: videoURL)
        self.isPresntingImagePicker = false
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

  @ViewBuilder
  private func _contentView() -> some View {
    if self.viewModel.isLoading {
      List {
        Text("Filename A")
        Text("Filename B")
        Text("Filename C")
      }
      .redacted(reason: .placeholder)
      .onAppear(perform: {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          self.viewModel.loadFilesFromCustomPhotoAlbum(for: self.type)
        }
      })

    } else if self.viewModel.assetIdentifiers.isEmpty {
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

  @ViewBuilder
  private func _assetIdentifiersList() -> some View {
    List {
      Section("Asset Identifiers") {
        ForEach(self.viewModel.assetIdentifiers, id: \.self) { assetIdentifier in
          NavigationLink {
            if self.type == .videos {
              VideoDetailsView(assetIdentifier: assetIdentifier)
            } else {
              PhotoDetailsView(assetIdentifier: assetIdentifier)
            }
          } label: {
            Text(assetIdentifier)
          }
        }
      }
    }
  }

  @ViewBuilder
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
        self.isPresntingImagePicker = true
      }
    }
  }
}
