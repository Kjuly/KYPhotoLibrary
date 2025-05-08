//
//  URL_KYPhotoLibraryTests.swift
//  KYPhotoLibraryTests
//
//  Created by Kjuly on 9/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import XCTest
import KYUnitTestResourceManager
@testable import KYPhotoLibrary

final class URL_KYPhotoLibraryTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  //
  // URL.ky_getExistingFileExtension()
  //
  func testGetExistingFileExtension() async throws {
    let fileManager: FileManager = .default
    let filename_video_01: String = KYUnitTestResourceFilename.video_mov_01_low
    let filename_video_02: String = KYUnitTestResourceFilename.video_mp4_02_low
    let localFileURL_video_01: URL = KYUnitTestResourceManager.localFileURL(with: filename_video_01)
    let localFileURL_video_02: URL = KYUnitTestResourceManager.localFileURL(with: filename_video_02)
    defer {
      try? KYUnitTestResourceManager.cacheFiles(from: [
        localFileURL_video_01,
        localFileURL_video_02,
      ])
    }

    // Make sure there are no local files before testing.
    try? fileManager.removeItem(at: localFileURL_video_01)
    try? fileManager.removeItem(at: localFileURL_video_02)

    // File doesn't exist.
    XCTAssertEqual(fileManager.fileExists(atPath: localFileURL_video_01.path), false)
    XCTAssertEqual(try localFileURL_video_01.ky_getExistingFileExtension(), nil)

    XCTAssertEqual(fileManager.fileExists(atPath: localFileURL_video_02.path), false)
    XCTAssertEqual(try localFileURL_video_02.ky_getExistingFileExtension(), nil)

    // Get the testable file.
    var testableFileURL: URL?
    testableFileURL = try await KYUnitTestResourceManager.getTestableFileURL(for: .video, with: filename_video_01)
    XCTAssertEqual(testableFileURL, localFileURL_video_01)
    XCTAssertEqual(fileManager.fileExists(atPath: localFileURL_video_01.path), true)
    XCTAssertEqual(try localFileURL_video_01.ky_getExistingFileExtension(), "mov")

//    testableFileURL = try await KYUnitTestResourceManager.getTestableFileURL(for: .video, with: filename_video_02)
//    XCTAssertEqual(testableFileURL, localFileURL_video_02)
//    XCTAssertEqual(fileManager.fileExists(atPath: localFileURL_video_02.path), true)
//    XCTAssertEqual(try localFileURL_video_02.ky_getExistingFileExtension(), "mp4")
  }
}
