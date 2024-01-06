//
//  ContentViewModel.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 6/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import UIKit
import AVFoundation
import KYPhotoLibrary

@MainActor
class ContentViewModel: ObservableObject {

  private var customPhotoAlbumName: String {
    return KYPhotoLibraryDemoApp.customPhotoAlbumName
  }

  @Published var isLoading: Bool = true
  @Published var assetIdentifiers: [String] = []

  @Published var error: ContentViewModelError?

  // MARK: - Action

  func loadFilesFromCustomPhotoAlbum() {
    KYPhotoLibrary.loadAssetIdentifiers(
      of: .image,
      fromAlbum: self.customPhotoAlbumName,
      limit: 0) { assetIdentifiers in
        DispatchQueue.main.async {
          self.assetIdentifiers = assetIdentifiers ?? []
          self.isLoading = false
        }
      }
  }

  func reqeustCameraAuthorization(completion: @escaping (_ authorized: Bool) -> Void) {
    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
      self.error = .cameraUnavailable
      completion(false)
      return
    }

    let status = AVCaptureDevice.authorizationStatus(for: .video)
    switch status {
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { authorized in
        completion(authorized)
      }

    case .restricted, .denied:
      self.error = .failedToAccessCamera
      completion(false)

    case .authorized:
      completion(true)

    @unknown default:
      completion(false)
    }
  }

  func didFinishPicking(_ image: UIImage) {
    KYPhotoLibrary.save(
      image: image,
      toAlbum: self.customPhotoAlbumName) { localIdentifier, _, _ in
        guard let localIdentifier else {
          return
        }
        DispatchQueue.main.async {
          self.assetIdentifiers.append(localIdentifier)
        }
      }
  }
}
