//
//  KYPhotoLibrary+Image.swift
//  KYPhotoPicker
//
//  Created by Kjuly on 30/6/2016.
//  Copyright © 2016 Kaijie Yu. All rights reserved.
//

import UIKit
import Photos

extension KYPhotoLibrary {

  /// Save image to a custom album
  ///
  /// If need to update UI in completion block, you need to do related tasks in main thread manually.
  ///
  /// - Parameters:
  ///   - image: Image to save
  ///   - albumName: Custom album name
  ///   - completion: A block to execute when complete
  ///
  public static func save(
    image: UIImage,
    toAlbum albumName: String,
    completion: ((_ localIdentifier: String?, _ image: UIImage, _ error: Error?) -> Void)?
  ) {
    assert(!albumName.isEmpty)

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

    let saveImageToAlbum = { (assetCollection: PHAssetCollection?, albumCreationError: Error?) in
      guard let assetCollection else {
        if let completion {
          completion(nil, image, albumCreationError)
        }
        return
      }

      var assetPlaceholder: PHObjectPlaceholder?

      PHPhotoLibrary.shared().performChanges {
        let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
        assetPlaceholder = createAssetRequest.placeholderForCreatedAsset

        let collectionChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
        collectionChangeRequest?.addAssets([assetPlaceholder] as NSFastEnumeration)

      } completionHandler: { (success: Bool, performChangesError: Error?) in
#if DEBUG
        if success {
          NSLog("Add Photo Succeeded: \(assetPlaceholder?.localIdentifier ?? "")")
        } else {
          NSLog("Add Photo Failed: \(performChangesError?.localizedDescription ?? "")")
        }
#endif // END #if DEBUG
        if let completion {
          completion(assetPlaceholder?.localIdentifier, image, performChangesError)
        }
      }
    }

    if let matchedAssetCollection {
      saveImageToAlbum(matchedAssetCollection, nil)
    } else {
      createAlbum(with: albumName, completion: saveImageToAlbum)
    }
  }

  /// Load one image w/ specific asset local identifier
  ///
  /// - Parameters:
  ///   - assetIdentifier: The asset unique identifier used in Photo Library.
  ///   - expectedSize: The expected size of image to be returned, default: zero.
  ///   - deliveryMode: The requested image quality and delivery priority, default: highQualityFormat.
  ///   - resizeMode: The mode that specifies how to resize the requested image, default: exact.
  ///   - completion: A block to execute when complete.
  ///
  public static func loadImage(
    with assetIdentifier: String,
    expectedSize: CGSize = .zero,
    deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat,
    resizeMode: PHImageRequestOptionsResizeMode = .exact,
    completion: @escaping (_ image: UIImage?) -> Void
  ) {
    guard let asset: PHAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject else {
      completion(nil)
      return
    }

    let targetSize = (CGSizeEqualToSize(expectedSize, .zero)
                      ? CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                      : expectedSize)

    let options = PHImageRequestOptions()
    options.deliveryMode = deliveryMode
    options.resizeMode = resizeMode

    let imageManager: PHImageManager = PHCachingImageManager.default()
    imageManager.requestImage(for: asset,
                              targetSize: targetSize,
                              contentMode: .aspectFit,
                              options: options) { result, _ in
      completion(result)
    }
  }

  /// Load multiple images from an album
  ///
  /// If need to update UI in completion block, you need to do related tasks in main thread manually.
  ///
  /// - Parameters:
  ///   - albumName: Custom album name.
  ///   - expectedSize: The expected size of image to be returned.
  ///   - deliveryMode: The requested image quality and delivery priority, default: highQualityFormat.
  ///   - resizeMode: The mode that specifies how to resize the requested image, default: exact.
  ///   - limit: The maximum number of images to fetch at one time.
  ///   - completion: A block to execute when complete.
  ///
  public static func loadImages(
    fromAlbum albumName: String,
    expectedSize: CGSize = .zero,
    deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat,
    resizeMode: PHImageRequestOptionsResizeMode = .exact,
    limit: Int,
    completion: (_ images: [UIImage]?) -> Void
  ) {
    if albumName.isEmpty {
      completion(nil)
      return
    }

    var images: [UIImage] = []

    let imageManager: PHImageManager = PHCachingImageManager.default()

    let options = PHImageRequestOptions()
    options.deliveryMode = deliveryMode
    options.resizeMode = resizeMode

    loadAssets(of: .image, fromAlbum: albumName, limit: limit) { assets in
      guard let assets, assets.count > 0 else {
        completion(nil)
        return
      }
      assets.enumerateObjects { asset, _, _ in
        let targetSize = (CGSizeEqualToSize(expectedSize, .zero)
                          ? CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                          : expectedSize)
        imageManager.requestImage(for: asset,
                                  targetSize: targetSize,
                                  contentMode: .aspectFit,
                                  options: options) { result, _ in
          if let result {
            images.append(result)
          }
        }
      }

      completion(images)
    }
  }
}
