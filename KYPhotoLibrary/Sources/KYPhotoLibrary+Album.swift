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
  ///   - createIfNotFound: Whether need to create the album if it's not found, default: true.
  ///
  /// - Returns: Asset collection for the found album; nil if not found.
  ///
  public static func getAlbum(with albumName: String, createIfNotFound: Bool = true) async throws -> PHAssetCollection? {
    let albums: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
    var matchedAssetCollection: PHAssetCollection?
    KYPhotoLibraryLog("Looking for Album: \"\(albumName)\"...")

    albums.enumerateObjects { (album, _, stop) in
      guard album.localizedTitle == albumName else {
        return
      }
      KYPhotoLibraryLog("Found Album: \(album.localIdentifier).")
      matchedAssetCollection = album
      stop.pointee = true
    }

    if createIfNotFound && matchedAssetCollection == nil {
      return try await createAlbum(with: albumName)
    } else {
      return matchedAssetCollection
    }
  }

  /// Create a new album with a specific name.
  ///
  /// - Parameter albumName: The new album name.
  ///
  /// - Returns: Asset collection for the created album.
  ///
  public static func createAlbum(with albumName: String) async throws -> PHAssetCollection {
    try await PHPhotoLibrary.shared().performChanges {
      _ = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
    }
    KYPhotoLibraryLog("Create album \"\(albumName)\" succeeded.")

    guard let albumAssetCollection: PHAssetCollection = try await getAlbum(with: albumName, createIfNotFound: false) else {
      throw AlbumError.albumNotFound(albumName)
    }
    return albumAssetCollection
  }
}
