//
//  KYPhotoLibrary+VideoExport_Legacy.swift
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

  /// Export a video from the Photo Library to the app's destination folder.
  ///
  /// If you need to cancel the request before it completes, pass this identifier to the
  ///   static `KYPhotoLibrary.cancelAssetRequest(_:)` method, e.g.,
  /// ```swift
  /// let requestID: PHImageRequestID? = KYPhotoLibrary.loadVideo(...)
  /// KYPhotoLibrary.cancelAssetRequest(requestID)
  /// ```
  ///
  /// - Parameters:
  ///   - assetIdentifier: The asset's unique identifier used in the Photo Library.
  ///   - requestOptions: Options specifying how Photos should handle the request and notify your app of progress or errors.
  ///   - exportOptions: Options specifying how and where to export the video.
  ///   - completion: The block to execute on completion.
  ///
  /// - Returns: A numeric identifier for the video request.
  ///
  public static func exportVideoFromPhotoLibrary(
    with assetIdentifier: String,
    requestOptions: PHVideoRequestOptions? = nil,
    exportOptions: KYPhotoLibraryVideoExportOptions,
    completion: @escaping (_ cachedVideoURL: URL?, _ error: Error?) -> Void
  ) -> PHImageRequestID? {

    guard let asset: PHAsset = assetFromIdentifier(assetIdentifier, for: .video) else {
      completion(nil, nil)
      return nil
    }

    return PHImageManager.default().requestExportSession(
      forVideo: asset,
      options: requestOptions,
      exportPreset: exportOptions.exportPreset
    ) { exportSession, _ in

      guard let exportSession else {
        DispatchQueue.main.async {
          completion(nil, nil)
        }
        return
      }

      let outputURL: URL = exportOptions.prepareUniqueDestinationURL(for: asset)
      exportSession.outputFileType = exportOptions.outputFileType
      exportSession.outputURL = outputURL
      exportSession.exportAsynchronously {
        switch exportSession.status {
        case .completed:
          KYPhotoLibraryLog("Export Session Completed")
          DispatchQueue.main.async {
            completion(outputURL, nil)
          }

        case .failed:
          KYPhotoLibraryLog("Export Session Failed: \(String(describing: exportSession.error))")
          DispatchQueue.main.async {
            completion(nil, exportSession.error)
          }

        case .cancelled:
          KYPhotoLibraryLog("Export Session Cancelled")
          DispatchQueue.main.async {
            completion(nil, nil)
          }

        default:
          KYPhotoLibraryLog("Export Session - Other Status: \(exportSession.status)")
        }
      }
    }
  }
}
