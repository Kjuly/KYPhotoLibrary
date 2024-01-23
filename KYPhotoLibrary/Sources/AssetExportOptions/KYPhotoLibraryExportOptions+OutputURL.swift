//
//  KYPhotoLibraryExportOptions+OutputURL.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 10/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

#if os(iOS)
import UIKit
#endif

extension KYPhotoLibraryExportOptions {

  // MARK: - Get Unique Destination URL - PHAsset

  /// **[PKG Internal Usage Only]** Prepare an output URL based on `destinationFolderURL` to cache the asset.
  ///
  /// If `shouldRemoveDuplicates = true`, the duplicated file will be removed; otherwise,
  ///   a unique filename with an index will be created if duplicated.
  ///
  /// - Parameter asset: PHAsset object from Photo Library (optional).
  ///
  /// - Returns: A full URL including folder path and filename with extension.
  ///
  func prepareOutputURL(for asset: PHAsset?) async throws -> URL {
    try _createFolderIfNeeded()

    KYPhotoLibraryLog("Current filename: \(self.filename)")
    await _prepareFilename(with: asset)

    var url: URL = self.destinationFolderURL.appendingPathComponent(self.filename)
    if !FileManager.default.fileExists(atPath: url.path) {
      return url
    }

    if self.shouldRemoveDuplicates {
      do {
        try FileManager.default.removeItem(at: url)
      } catch {
        KYPhotoLibraryLog("Failed to remove file at \(url)")
      }

    } else {
      let title: String = (self.filename as NSString).deletingPathExtension
      var uniqueFilename: String = self.filename
      var index: Int = 0
      repeat {
        index += 1
        uniqueFilename = "\(title) - \(index).\(self.fileExtension)"
        url = self.destinationFolderURL.appendingPathComponent(uniqueFilename)
      } while FileManager.default.fileExists(atPath: url.path)

      self.filename = uniqueFilename
      KYPhotoLibraryLog("Prepared unique filename: \(uniqueFilename)")
    }
    return url
  }

  private func _createFolderIfNeeded() throws {
    if FileManager.default.fileExists(atPath: self.destinationFolderURL.path) {
      return
    }
    try FileManager.default.createDirectory(at: self.destinationFolderURL, withIntermediateDirectories: true)
  }

  private func _prepareFilename(with asset: PHAsset?) async {
    if self.filename.isEmpty {
      if let asset, let assetResource: PHAssetResource = KYPhotoLibrary.assetResource(for: asset) {
        self.filename = assetResource.originalFilename
        self.fileExtension = (self.filename as NSString).pathExtension
        self.outputFileType = AVFileType(assetResource.uniformTypeIdentifier)
      } else {
        _resetFileToDefault()
      }

    } else {
      let fileExtension: String = (self.filename as NSString).pathExtension
      if fileExtension.isEmpty {
        if let asset, let assetResource: PHAssetResource = KYPhotoLibrary.assetResource(for: asset) {
          self.fileExtension = (assetResource.originalFilename as NSString).pathExtension
          self.filename = self.filename + "." + self.fileExtension
          self.outputFileType = AVFileType(assetResource.uniformTypeIdentifier)
        } else {
          _resetFileToDefault(with: self.filename)
        }

      } else {
        self.fileExtension = fileExtension.lowercased()

        if let fileType = AVFileType.ky_fromFileExtension(self.fileExtension) {
          self.outputFileType = fileType
        } else {
          // Unrecognized file extension, reset it to default one.
          _resetFileToDefault(with: (self.filename as NSString).deletingPathExtension)
        }
      }
    }
    KYPhotoLibraryLog("""
Updated:
- filename: \(self.filename)
- fileExtension: \(self.fileExtension)
- outputFileType: \(self.outputFileType)
""")
  }

  private func _resetFileToDefault(with filename: String? = nil) {
    if self.assetMediaType == .video {
      self.filename = (filename ?? "Untitled") + ".mp4"
      self.fileExtension = "mp4"
      self.outputFileType = .mp4

    } else {
      self.filename = (filename ?? "Untitled") + ".jpg"
      self.fileExtension = "jpg"
      self.outputFileType = .jpg
    }
  }
}
