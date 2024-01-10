//
//  AssetDetailsView+Photo.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 8/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI

extension AssetDetailsView {

  @ViewBuilder
  func photoView(with image: UIImage) -> some View {
    Image(uiImage: image)
      .resizable()
      .aspectRatio(contentMode: .fit)
  }
}
