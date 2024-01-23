//
//  KYPhotoLibraryExportOptions.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

public class KYPhotoLibraryExportOptions {

  public let assetMediaType: PHAssetMediaType

  /// The URL of the destination folder.
  public let destinationFolderURL: URL

  /// Filename with extension.
  public internal(set) var filename: String = ""
  public internal(set) var fileExtension: String = ""

  /// **Video Export Only** - File type for exporting videos from Photo Library, its generation depends on the filename extension.
  public internal(set) var outputFileType: AVFileType = .mp4

  /// **Video Export Only** - Preset to export video from Photo Library, default: AVAssetExportPresetPassthrough.
  ///
  /// This option will cause the output media to be resized based on the value provided.
  /// For further details, see the `presetName` of `AVAssetExportSession`.
  ///
  public let exportPreset: String

  /// **Video Export Only** - Specify a time range to be exported from the source, default: nil (the entire media will be exported).
  ///
  /// For further details, see the `timeRange` of `AVAssetExportSession`.
  ///
  public var timeRange: CMTimeRange?

  /// Whether duplicate files should be removed before saving.
  public let shouldRemoveDuplicates: Bool

  // MARK: - Init

  /// Initialize image export options.
  ///
  /// For the `filename`, if you don't provide a file extension or the file extension is invalid,
  ///   we will use the extension of the original file.
  ///
  /// - Parameters:
  ///   - destinationFolderURL: The URL of the destination folder.
  ///   - filename: Preferred filename with extension, default: nil (use the same filename in the Photo Library).
  ///   - shouldRemoveDuplicates: Whether duplicate files should be removed before saving; if not, a unique filename
  ///     with an index will be created if duplicated.
  ///
  public init(
    destinationFolderURL: URL,
    filename: String? = nil,
    shouldRemoveDuplicates: Bool = false
  ) {
    self.assetMediaType = .image

    self.destinationFolderURL = destinationFolderURL
    self.shouldRemoveDuplicates = shouldRemoveDuplicates

    if let filename {
      self.filename = filename
    }

    self.exportPreset = ""
  }

  /// Initialize video export options.
  ///
  /// For the `filename`, if you don't provide a file extension or the file extension is invalid,
  ///   we will use the extension of the original file in the Photo Library.
  ///
  /// - Parameters:
  ///   - destinationFolderURL: The URL of the destination folder.
  ///   - filename: Preferred filename with extension, default: nil (use the same filename in the Photo Library).
  ///   - exportPreset: Preset to export video from Photo Library, default: AVAssetExportPresetPassthrough.
  ///   - shouldRemoveDuplicates: Whether duplicate files should be removed before saving; if not, a unique filename
  ///     with an index will be created if duplicated.
  ///
  public init(
    destinationFolderURL: URL,
    filename: String? = nil,
    exportPreset: String = AVAssetExportPresetPassthrough,
    shouldRemoveDuplicates: Bool = false
  ) {
    self.assetMediaType = .video

    self.destinationFolderURL = destinationFolderURL
    self.exportPreset = exportPreset
    self.shouldRemoveDuplicates = shouldRemoveDuplicates

    if let filename {
      self.filename = filename
    }
  }
}
