//
//  UTType+KYPhotoLibrary.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 8/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers

extension UTType {

  // MARK: - Creation

  public static func ky_fromFile(with fileURL: URL) -> UTType? {
    if let fileExtension: String = ky_getFileExtensionFromURL(fileURL) {
      return UTType(filenameExtension: fileExtension)
    } else {
      return nil
    }
  }

  // MARK: - Get File Extension

  public static func ky_getFileExtensionFromURL(_ fileURL: URL) -> String? {
    let fileExtension: String = fileURL.pathExtension
    if fileExtension.isEmpty {
      return try? fileURL.ky_getExistingFileExtension()
    } else {
      return fileExtension
    }
  }

  public static func ky_getFileExtensionFromUniformTypeIdentifier(_ identifier: String) -> String? {
    guard let type = UTType(identifier) else {
      return nil
    }
    return type.ky_getFileExtension()
  }

  public func ky_getFileExtension() -> String? {
    return self.preferredFilenameExtension ?? self.tags[UTTagClass.filenameExtension]?.first
  }

  // MARK: - File Type Checking

  public func ky_isPhotoFileType() -> Bool {
    return conforms(to: .image)
  }

  public func ky_isVideoFileType() -> Bool {
    return conforms(to: .movie)
  }

  public func ky_isAudioFileType() -> Bool {
    return conforms(to: .audio)
  }
}
