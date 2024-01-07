//
//  PhotoDetailsView.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 6/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import KYPhotoLibrary

struct PhotoDetailsView: View {

  var assetIdentifier: String
  @StateObject private var viewModel = PhotoDetailsViewModel()

  var body: some View {
    if self.viewModel.isLoading {
      Text("Loading...")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
          self.viewModel.loadAsset(with: self.assetIdentifier)
        })
        .onDisappear(perform: self.viewModel.terminateAssetLoading)
    }
    else if let image = self.viewModel.loadedImage {
      Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: .fit)
    } else {
      Text("Image Not Found.")
        .font(.title)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}
