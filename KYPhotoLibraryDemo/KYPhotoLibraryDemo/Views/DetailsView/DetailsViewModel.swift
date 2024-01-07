//
//  DetailsViewModel.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import Photos
import KYPhotoLibrary

class DetailsViewModel: ObservableObject {

  @Published var isLoading: Bool = true
  var requestID: PHImageRequestID?

  func terminateAssetLoading() {
    KYPhotoLibrary.cancelAssetRequest(self.requestID)
  }
}
