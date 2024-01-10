//
//  KYPhotoLibraryVideoExportOptions.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

public class KYPhotoLibraryVideoExportOptions {

  /// The URL of the destination folder.
  let folderURL: URL

  /// Filename with extension.
  private(set) var filename: String = ""
  private(set) var fileExtension: String = ""

  /// Preset to export video from Photo Library, default: AVAssetExportPresetPassthrough.
  let exportPreset: String

  /// File type for exporting videos from Photo Library, its generation depends on the filename extension.
  private(set) var outputFileType: AVFileType = .mp4

  /// Whether duplicate files should be removed before saving.
  let shouldRemoveDuplicates: Bool

  // MARK: - Init

  /// Initialize video export options.
  ///
  /// For the `filename`, if you don't provide a file extension or the file extension is invalid,
  ///   we will use the extension of the original file in the Photo Library.
  ///
  /// - Parameters:
  ///   - folderURL: The URL of the destination folder.
  ///   - filename: Preferred filename with extension, default: nil (use the same filename in the Photo Library).
  ///   - exportPreset: Preset to export video from Photo Library, default: AVAssetExportPresetPassthrough.
  ///   - shouldRemoveDuplicates: Whether duplicate files should be removed before saving; if not, a unique filename
  ///     with an index will be created if duplicated.
  ///
  public init(
    folderURL: URL,
    filename: String? = nil,
    exportPreset: String = AVAssetExportPresetPassthrough,
    shouldRemoveDuplicates: Bool = false
  ) {
    self.folderURL = folderURL
    self.exportPreset = exportPreset
    self.shouldRemoveDuplicates = shouldRemoveDuplicates

    if let filename {
      self.filename = filename
    }
  }

  // MARK: - Destination URL

  /// Prepare a unique destination URL based on `folderURL` to cache the asset.
  ///
  /// If `shouldRemoveDuplicates = true`, the duplicated file will be removed; otherwise,
  ///   a unique filename with an index will be created if duplicated.
  ///
  /// - Returns: A full URL including folder path and filename with extension.
  ///
  func prepareUniqueDestinationURL(for asset: PHAsset) -> URL {
    _createFolderIfNeeded()

    KYPhotoLibraryLog("Current filename: \(self.filename)")
    _prepareFilename(with: asset)

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

  // MARK: - Private

  private func _createFolderIfNeeded() {
    if FileManager.default.fileExists(atPath: self.folderURL.path) {
      return
    }

    do {
      try FileManager.default.createDirectory(at: self.folderURL, withIntermediateDirectories: true)
    } catch {
      KYPhotoLibraryLog("Failed to create folder at \(self.folderURL)")
    }
  }

  private func _prepareFilename(with asset: PHAsset) {
    if self.filename.isEmpty {
      if let assetResource: PHAssetResource = KYPhotoLibrary.assetResource(for: asset) {
        self.filename = assetResource.originalFilename
        self.fileExtension = (self.filename as NSString).pathExtension
        self.outputFileType = AVFileType(assetResource.uniformTypeIdentifier)
      } else {
        _resetFileToDefault()
      }

    } else {
      let fileExtension: String = (self.filename as NSString).pathExtension
      if fileExtension.isEmpty {
        if let assetResource: PHAssetResource = KYPhotoLibrary.assetResource(for: asset) {
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
    self.filename = (filename ?? "Unknown") + ".mp4"
    self.fileExtension = "mp4"
    self.outputFileType = .mp4
  }
}
