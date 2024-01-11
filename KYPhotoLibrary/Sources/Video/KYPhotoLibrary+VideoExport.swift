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

  // MARK: - Error

  public enum VideoExportError: Error, LocalizedError {
    case assetNotFound(String)
    case failedToPrepareExportSession

    public var errorDescription: String? {
      switch self {
      case .assetNotFound(let assetIdentifier):
        return "Asset with identifier: \"\(assetIdentifier)\" not found."
      case .failedToPrepareExportSession:
        return "Failed to prepare export session."
      }
    }
  }

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
    exportOptions: KYPhotoLibraryAssetExportOptions
  ) async throws -> URL? {

    guard let asset: PHAsset = await assetFromIdentifier(assetIdentifier, for: .video) else {
      throw VideoExportError.assetNotFound(assetIdentifier)
    }
    //
    // Request a video export session.
    let exportSessionRequestActor = VideoExportSessionRequestActor()
    let session: AVAssetExportSession = try await withTaskCancellationHandler {
      KYPhotoLibraryLog("Start Export Session Request...")
      return try await exportSessionRequestActor.requestSession(
        asset: asset,
        requestOptions: requestOptions,
        exportOptions: exportOptions)
    } onCancel: {
      Task {
        KYPhotoLibraryLog("Cancel Export Session Request...")
        await exportSessionRequestActor.cancelRequst()
      }
    }

#if DEBUG
    KYPhotoLibraryDebug.simulateWaiting(.assetExport)
#endif
    //
    // Export video w/ the session prepared.
    try Task.checkCancellation()
    session.outputFileType = exportOptions.outputFileType
    session.outputURL = await exportOptions.prepareUniqueDestinationURL(for: asset)

    try Task.checkCancellation()
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

// MARK: - Video Export Session Request Actor

private actor VideoExportSessionRequestActor {

  var requestID: PHImageRequestID?

  func requestSession(
    asset: PHAsset,
    requestOptions: PHVideoRequestOptions?,
    exportOptions: KYPhotoLibraryAssetExportOptions
  ) async throws -> AVAssetExportSession {

    return try await withCheckedThrowingContinuation { continuation in
      self.requestID = PHImageManager.default().requestExportSession(
        forVideo: asset,
        options: requestOptions,
        exportPreset: exportOptions.exportPreset
      ) { exportSession, _ in
#if DEBUG
        KYPhotoLibraryDebug.simulateWaiting(.assetExport)
#endif
        self.requestID = nil

        if let exportSession {
          continuation.resume(returning: exportSession)
        } else {
          continuation.resume(throwing: KYPhotoLibrary.VideoExportError.failedToPrepareExportSession)
        }
      }
    }
  }

  func cancelRequst() async {
    guard let requestID = self.requestID else {
      return
    }
    PHImageManager.default().cancelImageRequest(requestID)
    self.requestID = nil
  }
}
