//
//  DemoAssetType.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation

enum DemoAssetType: Int {

  case archive = 0
  case photo
  case video

  var tabText: String {
    switch self {
    case .archive: return "Archives"
    case .photo: return "Photos"
    case .video: return "Videos"
    }
  }

  var tabIconName: String {
    switch self {
    case .archive: return "archivebox"
    case .photo: return "photo"
    case .video: return "film"
    }
  }

  var noMediaText: String {
    switch self {
    case .archive: return "No Cached Files"
    case .photo: return "No Photos"
    case .video: return "No Videos"
    }
  }

  var mediaNotFoundText: String {
    switch self {
    case .archive: return "File Not Found."
    case .photo: return "Image Not Found."
    case .video: return "Video Not Found."
    }
  }

  var pickMediaText: String {
    switch self {
    case .photo: return "Take Photo"
    case .video: return "Take Video"
    default:
      return ""
    }
  }
}
