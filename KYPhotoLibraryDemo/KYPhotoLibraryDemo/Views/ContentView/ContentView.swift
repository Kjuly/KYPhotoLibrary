//
//  ContentView.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 6/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI

struct ContentView: View {

  @StateObject private var viewModel = ContentViewModel()
  @State private var isPresntingImagePicker = false

  var body: some View {
    ZStack {
      Color(uiColor: .systemGroupedBackground)
        .ignoresSafeArea()

      _contentView()
    }
    .navigationTitle("KYPhotoLibrary Demo")
    .navigationBarTitleDisplayMode(.inline)
    .safeAreaInset(edge: .bottom, alignment: .center, content: _takePhotoButton)
    .fullScreenCover(isPresented: $isPresntingImagePicker) {
      DemoImagePicker(for: .camera) { pickedImage in
        self.viewModel.didFinishPicking(pickedImage)
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
          self.viewModel.loadFilesFromCustomPhotoAlbum()
        }
      })

    } else if self.viewModel.assetIdentifiers.isEmpty {
      VStack(alignment: .center) {
        Text("No Photos")
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
            PhotoPreviewView(assetIdentifier: assetIdentifier)
          } label: {
            Text(assetIdentifier)
          }
        }
      }
    }
  }

  @ViewBuilder
  private func _takePhotoButton() -> some View {
    Button(action: _takePhoto) {
      Text("Take Photo")
        .font(.body.bold())
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
    .padding()
  }

  private func _takePhoto() {
    self.viewModel.reqeustCameraAuthorization { authorized in
      if authorized {
        self.isPresntingImagePicker = true
      }
    }
  }
}
