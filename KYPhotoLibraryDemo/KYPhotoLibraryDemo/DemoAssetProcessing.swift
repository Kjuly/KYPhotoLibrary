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
  case request
  case cache
  case deleteCache
  case deleteFile

  var actionText: String {
    switch self {
    case .cache: return "Cache to App"
    case .deleteCache: return "Delete Cached File"
    case .deleteFile: return "Delete File"
    default:
      return ""
    }
  }

  var iconName: String {
    switch self {
    case .cache: return "arrow.down.to.line.circle"
    case .deleteCache: return "trash"
    case .deleteFile: return "trash"
    default:
      return ""
    }
  }

  var inProcessingText: String {
    switch self {
    case .load: return "Loading..."
    case .request: return "Requesting..."
    case .cache: return "Caching..."
    case .deleteCache, .deleteFile: return "Deleting..."
    default:
      return ""
    }
  }
}
