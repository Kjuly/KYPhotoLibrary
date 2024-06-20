//
//  AssetDetailsView+Video.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 8/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import AVKit

extension AssetDetailsView {

  func videoView(with asset: AVAsset) -> some View {
    VideoPlayer(player: AVPlayer(playerItem: AVPlayerItem(asset: asset)))
  }
}
