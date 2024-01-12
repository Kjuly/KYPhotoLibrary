//
//  AssetsListRowModel.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 12/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import Photos
import KYPhotoLibrary

struct AssetsListRowModel {

  let identifier: String
  let filename: String

  // MARK: - Init

  init(identifier: String, filename: String) {
    self.identifier = identifier
    self.filename = filename
  }

  init(from asset: PHAsset) {
    self.identifier = asset.localIdentifier
    self.filename = KYPhotoLibrary.originalFilename(for: asset) ?? asset.localIdentifier
  }
}
