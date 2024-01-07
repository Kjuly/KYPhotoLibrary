//
//  KYPhotoLibrary.swift
//  KYPhotoPicker
//
//  Created by Kjuly on 30/6/2016.
//  Copyright © 2016 Kaijie Yu. All rights reserved.
//

import Foundation
import Photos

public class KYPhotoLibrary {

  public typealias AlbumCreationCompletion = (_ assetCollection: PHAssetCollection?, _ error: Error?) -> Void

  /// Get a custom album with a specific name, if it exists.
  ///
  /// - Parameters:
  ///   - albumName: The album name
  ///
  public static func getAlbum(with albumName: String) -> PHAssetCollection? {
    let albums: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
    var matchedAssetCollection: PHAssetCollection?
    NSLog("Looking for Album: \"\(albumName)\"...")

    albums.enumerateObjects { (album, _, stop) in
      NSLog("Found Album: \(album.localIdentifier).")
      if album.localizedTitle == albumName {
        matchedAssetCollection = album
        stop.pointee = true
      }
    }
    return matchedAssetCollection
  }

  /// Create new album w/ the specific name
  ///
  /// - Parameters:
  ///   - albumName: New album name
  ///   - completion: A block to execute when complete
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
        NSLog("Create Album: \"\(albumName)\" Photo Succeed.")

        if let localIdentifier = albumPlaceholder?.localIdentifier {
          assetCollection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localIdentifier],
                                                                    options: nil).firstObject
        }
      } else {
        NSLog("Create Album: \"\(albumName)\" Failed: \(error?.localizedDescription ?? "")")
      }

      if let completion {
        completion(assetCollection, error)
      }
    }
  }

  /// Load assets of a type from an album.
  ///
  /// - Parameters:
  ///   - mediaType: Expected media type for asset
  ///   - albumName: Album name
  ///   - limit: The maximum number of assets to fetch at one time
  ///   - completion: A block to execute when complete
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
  ///   - mediaType: Expected media type for asset
  ///   - albumName: Album name
  ///   - limit: The maximum number of assets to fetch at one time
  ///   - completion: A block to execute when complete
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
}
