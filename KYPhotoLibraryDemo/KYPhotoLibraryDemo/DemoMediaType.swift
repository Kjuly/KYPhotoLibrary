//
//  DemoMediaType.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 7/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation

enum DemoMediaType: Int {

  case photos
  case videos

  var tabText: String {
    switch self {
    case .photos: return "Photos"
    case .videos: return "Videos"
    }
  }

  var tabIconName: String {
    switch self {
    case .photos: return "photo"
    case .videos: return "film"
    }
  }

  var noMediaText: String {
    switch self {
    case .photos: return "No Photos"
    case .videos: return "No Videos"
    }
  }

  var pickMediaText: String {
    switch self {
    case .photos: return "Take Photo"
    case .videos: return "Take Video"
    }
  }
}
