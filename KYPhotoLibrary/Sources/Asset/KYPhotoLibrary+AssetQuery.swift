//
//  KYPhotoLibrary+AssetQuery.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 30/6/2016.
//  Copyright © 2016 Kaijie Yu. All rights reserved.
//

import Foundation
import Photos

extension KYPhotoLibrary {

  // MARK: - Load Assets

  /// Load assets of a type from an album.
  ///
  /// - Parameters:
  ///   - mediaType: The expected media type of the assets.
  ///   - albumName: The album name.
  ///   - limit: The maximum number of assets to fetch at one time.
  ///
  /// - Returns: A fetch result that contains the requested PHAsset objects, or empty if no objects match the request.
  ///
  public static func loadAssets(
    of mediaType: PHAssetMediaType,
    fromAlbum albumName: String,
    limit: Int
  ) async throws -> PHFetchResult<PHAsset> {

    if albumName.isEmpty {
      throw CommonError.invalidAlbumName(albumName)
    }

    let albums: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
    let predicate = NSPredicate(format: "mediaType = %ld", mediaType.rawValue)

    var assets: PHFetchResult<PHAsset>?

    albums.enumerateObjects { (albumCollection, _, stop) in
      guard albumCollection.localizedTitle == albumName else {
        return
      }

      let fetchOptions = PHFetchOptions()
      fetchOptions.wantsIncrementalChangeDetails = true
      fetchOptions.predicate = predicate
      if limit != 0 {
        fetchOptions.fetchLimit = limit
      }
      assets = PHAsset.fetchAssets(in: albumCollection, options: fetchOptions)

      stop.pointee = true
    }

    return assets ?? PHFetchResult<PHAsset>()
  }

  /// Load asset identifiers of a type from an album.
  ///
  /// - Parameters:
  ///   - mediaType: The expected media type of the assets.
  ///   - albumName: The album name.
  ///   - limit: The maximum number of assets to fetch at one time.
  ///
  /// - Returns: An array of asset identifiers, or an empty array if no assets match the request.
  ///
  public static func loadAssetIdentifiers(
    of mediaType: PHAssetMediaType,
    fromAlbum albumName: String,
    limit: Int
  ) async throws -> [String] {

    if albumName.isEmpty {
      throw CommonError.invalidAlbumName(albumName)
    }

    let assets: PHFetchResult<PHAsset> = try await loadAssets(of: mediaType, fromAlbum: albumName, limit: limit)
    guard assets.firstObject != nil else {
      return []
    }

    var assetIdentifiers: [String] = []
    assets.enumerateObjects { (asset, _, _) in
      assetIdentifiers.append(asset.localIdentifier)
    }
    return assetIdentifiers
  }

  /// Cancels an asynchronous asset request.
  ///
  /// - Parameter requestID: The numeric identifier of the request to be canceled.
  ///
  public static func cancelAssetRequest(_ requestID: PHImageRequestID?) {
    if let requestID {
      PHCachingImageManager.default().cancelImageRequest(requestID)
    }
  }

  // MARK: - PHAsset from Asset Identifier

  /// Get PHAsset instance from an asset identifier.
  ///
  /// - Parameters:
  ///   - assetIdentifier: The asset's unique identifier used in the Photo Library.
  ///   - mediaType: The expected media type of the asset.
  ///
  public static func assetFromIdentifier(_ assetIdentifier: String, for mediaType: PHAssetMediaType) async -> PHAsset? {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "mediaType = %ld", mediaType.rawValue)
    fetchOptions.fetchLimit = 1
    return PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: fetchOptions).firstObject
  }

  /// Get PHAsset instances from an asset identifier array.
  ///
  /// - Parameters:
  ///   - assetIdentifiers: An array of the asset's unique identifier used in the Photo Library.
  ///   - mediaType: The expected media type of the asset.
  ///
  public static func assetsFromIdentifier(_ assetIdentifiers: [String], for mediaType: PHAssetMediaType) async -> PHFetchResult<PHAsset> {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "mediaType = %ld", mediaType.rawValue)
    return PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: fetchOptions)
  }
}
