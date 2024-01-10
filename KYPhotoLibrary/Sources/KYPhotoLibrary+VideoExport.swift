//
//  KYPhotoLibrary+VideoExport.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 10/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import Photos
import AVFoundation

extension KYPhotoLibrary {

  // MARK: - Export Video from Photo Library to App

  /// Export a video from the Photo Library to the app's destination folder asynchronously.
  ///
  /// Sample code:
  /// ```swift
  /// let task = Task {
  ///   do {
  ///     let cachedAssetURL: URL? =
  ///     try await KYPhotoLibrary.exportVideoFromPhotoLibrary(
  ///       with: assetIdentifier,
  ///       requestOptions: nil,
  ///       exportOptions: exportOptions)
  ///     // ... deal with `cachedAssetURL` if needed.
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
  ///   - requestOptions: Options specifying how Photos should handle the request and notify your app of progress or errors.
  ///   - exportOptions: Options specifying how and where to export the video.
  ///
  /// - Returns: A cached video URL; nil if failed.
  ///
  public static func exportVideoFromPhotoLibrary(
    with assetIdentifier: String,
    requestOptions: PHVideoRequestOptions? = nil,
    exportOptions: KYPhotoLibraryVideoExportOptions
  ) async throws -> URL? {

    guard let asset: PHAsset = assetFromIdentifier(assetIdentifier, for: .video) else {
      throw KYPhotoLibraryError.assetNotFound(assetIdentifier)
    }

    // Request an export session.
    let assetExportActor = KYPhotoLibraryAssetExportActor()
    let session: AVAssetExportSession = try await withTaskCancellationHandler {
      KYPhotoLibraryLog("Start Export Session Request...")
      return try await assetExportActor.requestExportSession(
        asset: asset,
        requestOptions: requestOptions,
        exportOptions: exportOptions)
    } onCancel: {
      Task {
        KYPhotoLibraryLog("Cancel Export Session Request...")
        await assetExportActor.cancelRequst()
      }
    }

#if DEBUG
    if KYPhotoLibrary.debug_shouldSimulateWaitingDuringAssetExport {
      try await Task.sleep(nanoseconds: 3_000_000_000)
    }
#endif
    try Task.checkCancellation()

    // Export video w/ the session prepared.
    session.outputFileType = exportOptions.outputFileType
    session.outputURL = exportOptions.prepareUniqueDestinationURL(for: asset)

    return try await withTaskCancellationHandler {
      KYPhotoLibraryLog("Start Export Session...")
      return try await _exportVideo(with: session)
    } onCancel: {
      KYPhotoLibraryLog("Cancel Export Session...")
      session.cancelExport()
    }
  }

  // MARK: - Private

  /// Export video with the session prepared.
  private static func _exportVideo(with session: AVAssetExportSession) async throws -> URL? {
    await session.export()

    switch session.status {
    case .completed:
      KYPhotoLibraryLog("Export Session Completed")
      return session.outputURL

    case .failed:
      KYPhotoLibraryLog("Export Session Failed: \(String(describing: session.error))")
      if let error = session.error {
        throw error
      } else {
        return nil
      }

    case .cancelled:
      KYPhotoLibraryLog("Export Session Cancelled")
      return nil

    default:
      KYPhotoLibraryLog("Export Session - Other Status: \(session.status)")
      return nil
    }
  }
}
