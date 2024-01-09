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

  public typealias AlbumCreationCompletion = (_ assetCollection: PHAssetCollection?, _ error: Error?) -> Void
  public typealias AssetSavingCompletion = (_ localIdentifier: String?, _ error: Error?) -> Void

  // MARK: - Custom Album

  /// Get a custom album with a specific name, if it exists.
  ///
  /// - Parameters:
  ///   - albumName: The album name
  ///
  public static func getAlbum(with albumName: String) -> PHAssetCollection? {
    let albums: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
    var matchedAssetCollection: PHAssetCollection?
    KYPhotoLibraryLog("Looking for Album: \"\(albumName)\"...")

    albums.enumerateObjects { (album, _, stop) in
      KYPhotoLibraryLog("Found Album: \(album.localIdentifier).")
      if album.localizedTitle == albumName {
        matchedAssetCollection = album
        stop.pointee = true
      }
    }
    return matchedAssetCollection
  }

  /// Create a new album with a specific name.
  ///
  /// - Parameters:
  ///   - albumName: The new album name.
  ///   - completion: The block to execute on completion.
  ///
  public static func createAlbum(
    with albumName: String,
    completion: AlbumCreationCompletion?
  ) {
    var albumPlaceholder: PHObjectPlaceholder?

    PHPhotoLibrary.shared().performChanges {
      let collectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
      albumPlaceholder = collectionChangeRequest.placeholderForCreatedAssetCollection

    } completionHandler: { (success: Bool, error: Error?) in
      var assetCollection: PHAssetCollection?
      if success {
        KYPhotoLibraryLog("Create Album: \"\(albumName)\" Photo Succeed.")

        if let localIdentifier = albumPlaceholder?.localIdentifier {
          assetCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localIdentifier],
                                                                    options: nil).firstObject
        }
      } else {
        KYPhotoLibraryLog("Create Album: \"\(albumName)\" Failed: \(error?.localizedDescription ?? "")")
      }

      if let completion {
        completion(assetCollection, error)
      }
    }
  }

  // MARK: - Load Assets

  /// Load assets of a type from an album.
  ///
  /// - Parameters:
  ///   - mediaType: The expected media type of the assets.
  ///   - albumName: The album name.
  ///   - limit: The maximum number of assets to fetch at one time.
  ///   - completion: The block to execute on completion.
  ///
  public static func loadAssets(
    of mediaType: PHAssetMediaType,
    fromAlbum albumName: String,
    limit: Int,
    completion: (_ assets: PHFetchResult<PHAsset>?) -> Void
  ) {
    if albumName.isEmpty {
      completion(nil)
      return
    }

    let albums: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
    let predicate = NSPredicate(format: "mediaType = %ld", mediaType.rawValue)

    var assets: PHFetchResult<PHAsset>?

    albums.enumerateObjects { (albumCollection, _, stop) in
      if albumCollection.localizedTitle != albumName {
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

    completion(assets)
  }

  /// Load asset identifiers of a type from an album.
  ///
  /// - Parameters:
  ///   - mediaType: The expected media type of the assets.
  ///   - albumName: The album name.
  ///   - limit: The maximum number of assets to fetch at one time.
  ///   - completion: The block to execute on completion.
  ///
  public static func loadAssetIdentifiers(
    of mediaType: PHAssetMediaType,
    fromAlbum albumName: String,
    limit: Int,
    completion: (_ assetIdentifiers: [String]?) -> Void
  ) {
    if albumName.isEmpty {
      completion(nil)
      return
    }

    loadAssets(of: mediaType, fromAlbum: albumName, limit: limit) { assets in
      guard let assets else {
        completion(nil)
        return
      }
      var assetIdentifiers: [String] = []

      assets.enumerateObjects { (asset, _, _) in
        assetIdentifiers.append(asset.localIdentifier)
      }
      completion(assetIdentifiers)
    }
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
  public static func assetFromIdentifier(_ assetIdentifier: String, for mediaType: PHAssetMediaType) -> PHAsset? {
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
  public static func assetsFromIdentifier(_ assetIdentifiers: [String], for mediaType: PHAssetMediaType) -> PHFetchResult<PHAsset> {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "mediaType = %ld", mediaType.rawValue)
    return PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: fetchOptions)
  }

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
