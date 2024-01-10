//
//  KYPhotoLibrary.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 30/6/2016.
//  Copyright © 2016 Kaijie Yu. All rights reserved.
//

import Foundation
import Photos

extension KYPhotoLibrary {

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
}
