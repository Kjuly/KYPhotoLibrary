//
//  KYPhotoLibraryAssetExportActor.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 10/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import Photos

actor KYPhotoLibraryAssetExportActor {

  private var requestID: PHImageRequestID?

  init() {

  }

  func requestExportSession(
    asset: PHAsset,
    requestOptions: PHVideoRequestOptions?,
    exportOptions: KYPhotoLibraryVideoExportOptions
  ) async throws -> AVAssetExportSession {

    return try await withCheckedThrowingContinuation { continuation in
      self.requestID = PHImageManager.default().requestExportSession(
        forVideo: asset,
        options: requestOptions,
        exportPreset: exportOptions.exportPreset
      ) { exportSession, _ in
#if DEBUG
        if KYPhotoLibrary.debug_shouldSimulateWaitingDuringAssetExport {
          Task {
            try await Task.sleep(nanoseconds: 3_000_000_000)
          }
        }
#endif
        self.requestID = nil

        if let exportSession {
          continuation.resume(returning: exportSession)
        } else {
          continuation.resume(throwing: KYPhotoLibraryError.failedToPrepareExportSession)
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
