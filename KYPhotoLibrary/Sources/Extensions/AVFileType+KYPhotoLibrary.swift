//
//  AVFileType+KYPhotoLibrary.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 8/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import AVFoundation
import UniformTypeIdentifiers

extension AVFileType {

  static func ky_fromFileExtension(_ fileExtension: String) -> AVFileType? {
    if fileExtension.isEmpty {
      return nil
    } else if let utType = UTType(filenameExtension: fileExtension) {
      return AVFileType(utType.identifier)
    } else {
      return nil
    }
  }
}
