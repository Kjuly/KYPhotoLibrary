//
//  KYPhotoLibrary.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 30/6/2016.
//  Copyright © 2016 Kaijie Yu. All rights reserved.
//

import Foundation
import Photos

public class KYPhotoLibrary {

#if DEBUG
  static let debug_shouldSimulateWaitingDuringAssetExport: Bool = false
#endif

  public typealias AlbumCreationCompletion = (_ assetCollection: PHAssetCollection?, _ error: Error?) -> Void
  public typealias AssetSavingCompletion = (_ localIdentifier: String?, _ error: Error?) -> Void
}
