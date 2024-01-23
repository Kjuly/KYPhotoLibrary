//
//  KYPhotoLibraryConfiguration.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 19/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit

public struct KYPhotoLibraryThumbnailDefaults {

  public static let maxSideLengthForCompactDevice: CGFloat = 256
  public static let maxSideLengthForWideDevice: CGFloat = 512

  /// Maximum thumbnail size depends on device size.
  public static var maxSize: CGSize {
    return (UIDevice.ky_isCompact ? maxSizeForCompactDevice : maxSizeForWideDevice)
  }

  /// Maximum thumbnail size for compact devices such as iPhone.
  public static var maxSizeForCompactDevice: CGSize {
    return CGSize(width: maxSideLengthForCompactDevice, height: maxSideLengthForCompactDevice)
  }

  /// Maximum thumbnail size for wide devices (e.g. iPad, Mac).
  public static var maxSizeForWideDevice: CGSize {
    return CGSize(width: maxSideLengthForWideDevice, height: maxSideLengthForWideDevice)
  }
}

#else
public struct KYPhotoLibraryThumbnailDefaults {

  public static let maxSideLengthForWideDevice: CGFloat = 512

  /// Maximum thumbnail size.
  public static var maxSize: CGSize {
    return CGSize(width: maxSideLengthForWideDevice, height: maxSideLengthForWideDevice)
  }
}

#endif
