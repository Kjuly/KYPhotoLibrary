//
//  VideoDetailsViewModel.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import AVFoundation
import KYPhotoLibrary

class VideoDetailsViewModel: DetailsViewModel {

  @Published var playerItem: AVPlayerItem?

  func loadAsset(with assetIdentifier: String) {
    self.requestID = KYPhotoLibrary.loadVideo(with: assetIdentifier) { [weak self] videoAsset in
      guard let self else {
        return
      }
      if let videoAsset {
        self.playerItem = AVPlayerItem(asset: videoAsset)
      } else {
        self.playerItem = nil
      }
      self.requestID = nil
      self.isLoading = false
    }
  }
}
