//
//  PhotoPreviewViewModel.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import KYPhotoLibrary

class PhotoDetailsViewModel: DetailsViewModel {

  @Published var loadedImage: UIImage?

  func loadAsset(with assetIdentifier: String) {
    self.requestID = KYPhotoLibrary.loadImage(with: assetIdentifier) { [weak self] image in
      guard let self else {
        return
      }
      if let image {
        self.loadedImage = image
      } else {
        self.loadedImage = nil
      }
      self.requestID = nil
      self.isLoading = false
    }
  }
}
