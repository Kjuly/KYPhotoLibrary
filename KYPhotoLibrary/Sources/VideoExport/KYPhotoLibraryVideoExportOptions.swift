//
//  KYPhotoLibraryVideoExportOptions.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import AVFoundation

public class KYPhotoLibraryVideoExportOptions {

  /// The URL of the destination folder.
  public let folderURL: URL

  /// Filename with extension.
  public internal(set) var filename: String = ""
  public internal(set) var fileExtension: String = ""

  /// Preset to export video from Photo Library, default: AVAssetExportPresetPassthrough.
  public let exportPreset: String

  /// File type for exporting videos from Photo Library, its generation depends on the filename extension.
  public internal(set) var outputFileType: AVFileType = .mp4

  /// Whether duplicate files should be removed before saving.
  public let shouldRemoveDuplicates: Bool

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
}