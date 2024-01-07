//
//  VideoDetailsView.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import AVKit
import Photos
import KYPhotoLibrary

struct VideoDetailsView: View {

  var assetIdentifier: String
  @StateObject private var viewModel = VideoDetailsViewModel()

  var body: some View {
    if self.viewModel.isLoading {
      Text("Loading...")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: {
          self.viewModel.loadAsset(with: self.assetIdentifier)
        })
        .onDisappear(perform: self.viewModel.terminateAssetLoading)
    }
    else if let playerItem = self.viewModel.playerItem {
      VideoPlayer(player: AVPlayer(playerItem: playerItem))
    } else {
      Text("Video Not Found.")
        .font(.title)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }
}
