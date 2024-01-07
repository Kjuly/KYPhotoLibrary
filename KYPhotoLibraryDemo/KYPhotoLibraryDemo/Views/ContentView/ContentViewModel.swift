//
//  ContentViewModel.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 6/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
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

  func loadFilesFromCustomPhotoAlbum(for type: DemoMediaType) {
    let mediaType: PHAssetMediaType = (type == .videos ? .video : .image)
    KYPhotoLibrary.loadAssetIdentifiers(
      of: mediaType,
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

  func didFinishPicking(with image: UIImage?, or videoURL: URL?) {
    let completion: KYPhotoLibrary.AssetSavingCompletion = { localIdentifier, error in
      if let localIdentifier {
        DispatchQueue.main.async {
          self.assetIdentifiers.append(localIdentifier)
        }
      } else if let error {
        self.error = .failedToSaveAsset(error.localizedDescription)
      }
    }

    if let image {
      KYPhotoLibrary.saveImage(image, toAlbum: self.customPhotoAlbumName, completion: completion)
    } else if let videoURL {
      KYPhotoLibrary.saveVideo(with: videoURL, toAlbum: self.customPhotoAlbumName, completion: completion)
    }
  }
}
