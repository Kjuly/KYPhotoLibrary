//
//  KYPhotoLibrary+ImageExport.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 11/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

extension KYPhotoLibrary {

  // MARK: - Error

  public enum ImageExportError: Error, LocalizedError {
    case assetNotFound(String)
    case failedToRequestOriginalImageData
    case failedToRequestImageDataForType(String, String)

    public var errorDescription: String? {
      switch self {
      case .assetNotFound(let assetIdentifier):
        return "Asset with identifier: \"\(assetIdentifier)\" not found."
      case .failedToRequestOriginalImageData:
        return "Failed to request image data."
      case .failedToRequestImageDataForType(let typeIdentifier, let errorMessage):
        return "Failed to request image data for type: \(typeIdentifier), error: \(errorMessage)."
      }
    }
  }

  // MARK: - Export Image from Photo Library to App

  /// Export an original image from the Photo Library to the app's destination folder.
  ///
  /// Sample code:
  /// ```swift
  /// let task = Task {
  ///   do {
  ///     let outputURL: URL? =
  ///     try await KYPhotoLibrary.exportImageFromPhotoLibrary(
  ///       with: assetIdentifier,
  ///       requestOptions: requestOptions,
  ///       exportOptions: exportOptions)
  ///     // ... deal with `outputURL` if needed.
  ///   } catch {
  ///     // ... handle `error` here.
  ///   }
  /// }
  /// // Just use `task.cancel()` if you need to cancel the request
  /// //   before it completes.
  /// ```
  ///
  /// - Parameters:
  ///   - assetIdentifier: The asset's unique identifier used in the Photo Library.
  ///   - expectedSize: The expected size of the image to export, default: zero (original size).
  ///   - exportOptions: Options specifying how and where to export the image.
  ///
  /// - Returns: The exported image URL.
  ///
  public static func exportImageFromPhotoLibrary(
    with assetIdentifier: String,
    requestOptions: PHImageRequestOptions?,
    exportOptions: KYPhotoLibraryAssetExportOptions
  ) async throws -> URL {

    guard let asset: PHAsset = await assetFromIdentifier(assetIdentifier, for: .image) else {
      throw AssetError.assetNotFound(assetIdentifier)
    }

    let outputURL: URL = await exportOptions.prepareUniqueOutputURL(for: asset)

    // Request original image data.
    let imageDataRequestActor = ImageDataRequestActor()
    let imageData: Data = try await withTaskCancellationHandler {
      KYPhotoLibraryLog("Start Image Data Request...")
      return try await imageDataRequestActor.requestOriginalImageData(asset: asset, requestOptions: requestOptions)
    } onCancel: {
      Task {
        KYPhotoLibraryLog("Cancel Image Data Request...")
        await imageDataRequestActor.cancelRequst()
      }
    }
    // Output image.
    try Task.checkCancellation()
    try imageData.write(to: outputURL, options: .atomic)
    KYPhotoLibraryLog("Exported image to \(outputURL).")
    return outputURL
  }

  /// Export a image to the app's destination folder.
  ///
  /// - Parameters:
  ///   - image: The image to export.
  ///   - exportOptions: Options specifying how and where to export the image.
  ///
  /// - Returns: The exported image URL.
  ///
  public static func exportImage(
    _ image: UIImage,
    exportOptions: KYPhotoLibraryAssetExportOptions
  ) async throws -> URL {

    let outputURL: URL = await exportOptions.prepareUniqueOutputURL(for: nil)

    // Request image data for type.
    let imageDataRequestActor = ImageDataRequestActor()
    let imageData: Data = try await withTaskCancellationHandler {
      KYPhotoLibraryLog("Start Image Data Request...")
      return try await imageDataRequestActor.requestImageData(
        forTpye: exportOptions.outputFileType.rawValue,
        image: image)

    } onCancel: {
      Task {
        KYPhotoLibraryLog("Cancel Image Data Request...")
        await imageDataRequestActor.cancelRequst()
      }
    }
    // Output image.
    try Task.checkCancellation()
    try imageData.write(to: outputURL, options: .atomic)
    KYPhotoLibraryLog("Exported image to \(outputURL).")
    return outputURL
  }
}

// MARK: - Image Data Request Actor

private actor ImageDataRequestActor {

  private var requestID: PHImageRequestID?
  private var progress: Progress?

  func requestOriginalImageData(asset: PHAsset, requestOptions: PHImageRequestOptions?) async throws -> Data {
    return try await withCheckedThrowingContinuation { continuation in
      self.requestID = PHImageManager.default().requestImageDataAndOrientation(
        for: asset,
        options: requestOptions
      ) { data, _, _, _ in // imageData: NSData, dataUTI: String, orientation: CGImagePropertyOrientation, info: [AnyHashable : Any]?
#if DEBUG
        KYPhotoLibraryDebug.simulateWaiting(.assetExport)
#endif
        if let data {
          continuation.resume(returning: data)
        } else {
          continuation.resume(throwing: KYPhotoLibrary.ImageExportError.failedToRequestOriginalImageData)
        }
      }
    }
  }

  func requestImageData(forTpye typeIdentifier: String, image: UIImage) async throws -> Data {
    return try await withCheckedThrowingContinuation { continuation in
      self.progress = image.loadData(withTypeIdentifier: typeIdentifier) { data, error in
#if DEBUG
        KYPhotoLibraryDebug.simulateWaiting(.assetExport)
#endif
        if let data {
          continuation.resume(returning: data)
        } else {
          continuation.resume(throwing: KYPhotoLibrary.ImageExportError.failedToRequestImageDataForType(
            typeIdentifier, error?.localizedDescription ?? ""))
        }
      }
    }
  }

  func cancelRequst() async {
    if let requestID = self.requestID {
      PHImageManager.default().cancelImageRequest(requestID)
      self.requestID = nil

    } else if let progress = self.progress {
      progress.cancel()
      self.progress = nil
    }
  }
}
