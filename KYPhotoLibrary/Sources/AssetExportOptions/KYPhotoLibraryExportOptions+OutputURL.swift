//
//  KYPhotoLibraryExportOptions+OutputURL.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 10/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

extension KYPhotoLibraryExportOptions {

  // MARK: - Get Unique Destination URL - PHAsset

  /// **[PKG Internal Usage Only]** Prepare a unique output URL based on `folderURL` to cache the asset.
  ///
  /// If `shouldRemoveDuplicates = true`, the duplicated file will be removed; otherwise,
  ///   a unique filename with an index will be created if duplicated.
  ///
  /// - Parameter asset: PHAsset object from Photo Library (optional).
  ///
  /// - Returns: A full URL including folder path and filename with extension.
  ///
  func prepareUniqueOutputURL(for asset: PHAsset?) async -> URL {
    await _createFolderIfNeeded()

    KYPhotoLibraryLog("Current filename: \(self.filename)")
    await _prepareFilename(with: asset)

    var url: URL = self.folderURL.appendingPathComponent(self.filename)
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
      let filenameWithoutExt: String = (self.filename as NSString).deletingPathExtension
      var adjustedUniqueFilename: String = self.filename
      var index: Int = 0
      repeat {
        index += 1
        adjustedUniqueFilename = "\(filenameWithoutExt) - \(index).\(self.fileExtension)"
        url = self.folderURL.appendingPathComponent(adjustedUniqueFilename)
      } while FileManager.default.fileExists(atPath: url.path)

      self.filename = adjustedUniqueFilename
      KYPhotoLibraryLog("Adjusted unique filename: \(adjustedUniqueFilename)")
    }
    return url
  }

  private func _createFolderIfNeeded() async {
    if FileManager.default.fileExists(atPath: self.folderURL.path) {
      return
    }

    do {
      try FileManager.default.createDirectory(at: self.folderURL, withIntermediateDirectories: true)
    } catch {
      KYPhotoLibraryLog("Failed to create folder at \(self.folderURL)")
    }
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
