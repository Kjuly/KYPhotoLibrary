//
//  AssetsViewModel.swift
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
class AssetsViewModel: ObservableObject {

  private var customPhotoAlbumName: String {
    return KYPhotoLibraryDemoApp.customPhotoAlbumName
  }

  @Published var isLoading: Bool = true
  @Published var assetIdentifiers: [String] = []

  @Published var error: AssetsViewModelError?

  // MARK: - Action

  func loadFilesFromCustomPhotoAlbum(for type: DemoAssetType) async {
    do {
      self.assetIdentifiers = try await KYPhotoLibrary.loadAssetIdentifiers(
        of: (type == .video ? .video : .image),
        fromAlbum: self.customPhotoAlbumName,
        limit: 0)
    } catch {
      NSLog("Faield to load assets of \(type.tabText), error: \(error.localizedDescription)")
      self.assetIdentifiers = []
    }
    self.isLoading = false
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

  func didFinishPicking(with image: UIImage?, or videoURL: URL?) async {
    do {
      var localIdentifier: String?
      if let image {
        localIdentifier = try await KYPhotoLibrary.saveImage(image, toAlbum: self.customPhotoAlbumName)
      } else if let videoURL {
        localIdentifier = try await KYPhotoLibrary.saveVideo(with: videoURL, toAlbum: self.customPhotoAlbumName)
      }

      if let localIdentifier {
        self.assetIdentifiers.append(localIdentifier)
      }

    } catch {
      self.error = .failedToSaveAsset(error.localizedDescription)
    }
  }
}
