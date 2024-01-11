//
//  KYPhotoLibrary+AssetResource.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 30/6/2016.
//  Copyright © 2016 Kaijie Yu. All rights reserved.
//

import Foundation
import Photos

extension KYPhotoLibrary {

  // MARK: - PHAssetResource from PHAsset

  /// Get the asset resource of the PHAsset instance.
  ///
  /// PHAssetResource is an underlying data resource associated with a photo, video, or Live Photo
  ///   asset in the Photos library.
  ///
  public static func assetResource(for assetItem: PHAsset) -> PHAssetResource? {
    let assetResources: [PHAssetResource] = PHAssetResource.assetResources(for: assetItem)

    var appropriateAssetResource: PHAssetResource?
    if assetItem.mediaType == .image {
      appropriateAssetResource = assetResources.first {
        $0.type == .photo ||
        $0.type == .alternatePhoto ||
        $0.type == .fullSizePhoto ||
        $0.type == .adjustmentBasePhoto
      }
    } else if assetItem.mediaType == .video {
      appropriateAssetResource = assetResources.first {
        $0.type == .video ||
        $0.type == .fullSizeVideo ||
        $0.type == .pairedVideo ||
        $0.type == .fullSizePairedVideo ||
        $0.type == .adjustmentBasePairedVideo ||
        $0.type == .adjustmentBaseVideo
      }
    }
    return appropriateAssetResource ?? assetResources.first
  }

  /// Get the original filename of the PHAsset instance.
  public static func originalFilename(for assetItem: PHAsset) -> String? {
    return assetResource(for: assetItem)?.originalFilename
  }
}
