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

  public static func ky_fromFile(with fileURL: URL) -> UTType? {
    let fileExtension: String = (fileURL.lastPathComponent as NSString).pathExtension
    return UTType(filenameExtension: fileExtension)
  }

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
