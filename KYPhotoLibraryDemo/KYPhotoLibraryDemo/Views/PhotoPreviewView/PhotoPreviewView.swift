//
//  PhotoPreviewView.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 6/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import KYPhotoLibrary

struct PhotoPreviewView: View {

  var assetIdentifier: String

  @State private var isLoading: Bool = true
  @State private var loadedImage: UIImage?

  var body: some View {
    if self.isLoading {
      Text("Loading...")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: _loadImage)
    }
    else if let image = self.loadedImage {
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

  private func _loadImage() {
    KYPhotoLibrary.loadImage(with: self.assetIdentifier) { image in
      if let image {
        self.loadedImage = image
      } else {
        self.loadedImage = nil
      }
      self.isLoading = false
    }
  }
}
