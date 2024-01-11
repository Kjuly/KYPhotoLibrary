//
//  DemoAssetProcessing.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 8/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation

enum DemoAssetProcessing: Int {

  case none = 0
  case load
  case cacheFile
  case deleteCachedFile
  case saveAssetToAlbum
  case deleteFileFromPhotoLibrary

  var actionText: String {
    switch self {
    case .cacheFile: return "Cache to App"
    case .deleteCachedFile: return "Delete Cached File"
    case .saveAssetToAlbum: return "Save File to Album"
    case .deleteFileFromPhotoLibrary: return "Delete File from Photo Library"
    default:
      return ""
    }
  }

  var iconName: String {
    switch self {
    case .cacheFile: return "arrow.down.to.line.circle"
    case .saveAssetToAlbum: return "photo"
    case .deleteCachedFile, .deleteFileFromPhotoLibrary: return "trash"
    default:
      return ""
    }
  }

  var inProcessingText: String {
    switch self {
    case .load: return "Loading..."
    case .cacheFile: return "Caching..."
    case .saveAssetToAlbum: return "Saving..."
    case .deleteCachedFile, .deleteFileFromPhotoLibrary: return "Deleting..."
    default:
      return ""
    }
  }
}
