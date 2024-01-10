//
//  UTType_KYPhotoLibraryTests.swift
//  KYPhotoLibraryTests
//
//  Created by Kjuly on 8/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import XCTest
import UniformTypeIdentifiers
import KYUnitTestResourceManager
@testable import KYPhotoLibrary

final class UTType_KYPhotoLibraryTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  // MARK: - Tests - Creation

  //
  // static UTType.ky_fromFile(with:)
  //
  func testCreationFromFileURL() async throws {
    let fileManager: FileManager = .default

    let filename_image_01: String = KYUnitTestResourceFilename.image_png_01_small
    let filename_image_02: String = KYUnitTestResourceFilename.image_jpg_02
    let filename_image_03: String = KYUnitTestResourceFilename.image_gif_01
    let filename_video_01: String = KYUnitTestResourceFilename.video_mov_01_low
    let filename_video_02: String = KYUnitTestResourceFilename.video_mp4_02_low
    let localFileURL_image_01: URL = KYUnitTestResourceManager.localFileURL(with: filename_image_01)
    let localFileURL_image_02: URL = KYUnitTestResourceManager.localFileURL(with: filename_image_02)
    let localFileURL_image_03: URL = KYUnitTestResourceManager.localFileURL(with: filename_image_03)
    let localFileURL_video_01: URL = KYUnitTestResourceManager.localFileURL(with: filename_video_01)
    let localFileURL_video_02: URL = KYUnitTestResourceManager.localFileURL(with: filename_video_02)

    let filename_image_01_withoutExtension: String = (filename_image_01 as NSString).deletingPathExtension
    let localFileURL_image_01_withoutExtension: URL = KYUnitTestResourceManager.localFileURL(with: filename_image_01_withoutExtension)

    defer {
      try? fileManager.removeItem(at: localFileURL_image_01_withoutExtension)
      try? KYUnitTestResourceManager.cacheFiles(from: [
        localFileURL_image_01,
        localFileURL_image_02,
        localFileURL_image_03,
        localFileURL_video_01,
        localFileURL_video_02,
      ])
    }

    XCTAssertEqual(UTType.ky_fromFile(with: localFileURL_image_01), .png)
    XCTAssertEqual(UTType.ky_fromFile(with: localFileURL_image_02), .jpeg)
    XCTAssertEqual(UTType.ky_fromFile(with: localFileURL_image_03), .gif)
    XCTAssertEqual(UTType.ky_fromFile(with: localFileURL_video_01), .quickTimeMovie)
    XCTAssertEqual(UTType.ky_fromFile(with: localFileURL_video_02), .mpeg4Movie)

    try? fileManager.removeItem(at: localFileURL_image_01_withoutExtension) // Make sure file doesn't exist.
    XCTAssertEqual(UTType.ky_getFileExtensionFromURL(localFileURL_image_01_withoutExtension), nil)

    // Get the testable file.
    let testableFileURL: URL? = try await KYUnitTestResourceManager.getTestableFileURL(for: .image, with: filename_image_01)
    XCTAssertEqual(testableFileURL, localFileURL_image_01)
    XCTAssertEqual(fileManager.fileExists(atPath: localFileURL_image_01.path), true)

    // Copy the file to a file without extension.
    try? fileManager.copyItem(at: localFileURL_image_01, to: localFileURL_image_01_withoutExtension)
    XCTAssertEqual(fileManager.fileExists(atPath: localFileURL_image_01_withoutExtension.path), true)

    XCTAssertEqual(UTType.ky_fromFile(with: localFileURL_image_01), .png)
    XCTAssertEqual(UTType.ky_fromFile(with: localFileURL_image_01_withoutExtension), nil)
  }

  // MARK: - Tests - Get File Extension

  //
  // static UTType.ky_getFileExtensionFromURL(_:)
  //
  func testGetFileExtensionFromURL() async throws {
    let fileManager: FileManager = .default

    let filename_image_01: String = KYUnitTestResourceFilename.image_png_01_small
    let filename_image_02: String = KYUnitTestResourceFilename.image_jpg_02
    let filename_image_03: String = KYUnitTestResourceFilename.image_gif_01
    let filename_video_01: String = KYUnitTestResourceFilename.video_mov_01_low
    let filename_video_02: String = KYUnitTestResourceFilename.video_mp4_02_low
    let localFileURL_image_01: URL = KYUnitTestResourceManager.localFileURL(with: filename_image_01)
    let localFileURL_image_02: URL = KYUnitTestResourceManager.localFileURL(with: filename_image_02)
    let localFileURL_image_03: URL = KYUnitTestResourceManager.localFileURL(with: filename_image_03)
    let localFileURL_video_01: URL = KYUnitTestResourceManager.localFileURL(with: filename_video_01)
    let localFileURL_video_02: URL = KYUnitTestResourceManager.localFileURL(with: filename_video_02)

    let filename_video_01_withoutExtension: String = (filename_video_01 as NSString).deletingPathExtension
    let localFileURL_video_01_withoutExtension: URL = KYUnitTestResourceManager.localFileURL(with: filename_video_01_withoutExtension)

    defer {
      try? fileManager.removeItem(at: localFileURL_video_01_withoutExtension)
      try? KYUnitTestResourceManager.cacheFiles(from: [
        localFileURL_image_01,
        localFileURL_image_02,
        localFileURL_image_03,
        localFileURL_video_01,
        localFileURL_video_02,
      ])
    }

    XCTAssertEqual(UTType.ky_getFileExtensionFromURL(localFileURL_image_01), "png")
    XCTAssertEqual(UTType.ky_getFileExtensionFromURL(localFileURL_image_02), "jpg")
    XCTAssertEqual(UTType.ky_getFileExtensionFromURL(localFileURL_image_03), "gif")
    XCTAssertEqual(UTType.ky_getFileExtensionFromURL(localFileURL_video_01), "mov")
    XCTAssertEqual(UTType.ky_getFileExtensionFromURL(localFileURL_video_02), "mp4")

    try? fileManager.removeItem(at: localFileURL_video_01_withoutExtension) // Make sure file doesn't exist.
    XCTAssertEqual(UTType.ky_getFileExtensionFromURL(localFileURL_video_01_withoutExtension), nil)

    // Get the testable file.
    let testableFileURL: URL? = try await KYUnitTestResourceManager.getTestableFileURL(for: .image, with: filename_video_01)
    XCTAssertEqual(testableFileURL, localFileURL_video_01)
    XCTAssertEqual(fileManager.fileExists(atPath: localFileURL_video_01.path), true)

    // Copy the file to a file without extension.
    try? fileManager.copyItem(at: localFileURL_video_01, to: localFileURL_video_01_withoutExtension)
    XCTAssertEqual(fileManager.fileExists(atPath: localFileURL_video_01_withoutExtension.path), true)

    XCTAssertEqual(UTType.ky_getFileExtensionFromURL(localFileURL_video_01), "mov")
    XCTAssertEqual(UTType.ky_getFileExtensionFromURL(localFileURL_video_01_withoutExtension), nil)
  }

  //
  // static UTType.ky_getFileExtensionFromUniformTypeIdentifier(_:)
  //
  func testGetFileExtensionFromUniformTypeIdentifier() throws {
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.image"), nil)
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.jpeg"), "jpeg")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.tiff"), "tiff")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("com.compuserve.gif"), "gif")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.png"), "png")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("com.apple.icns"), "icns")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("com.microsoft.bmp"), "bmp")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("com.microsoft.ico"), "ico")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.camera-raw-image"), nil)
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.svg-image"), "svg")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("org.webmproject.webp"), "webp")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("com.apple.live-photo"), nil)
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.heif"), "heif")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.heic"), "heic")

    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.movie"), nil)
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.video"), nil)
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("com.apple.quicktime-movie"), "mov")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.mpeg"), "mpg")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.mpeg-2-video"), "m2v")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.mpeg-2-transport-stream"), "ts")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.mpeg-4"), "mp4")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("com.apple.protected-mpeg-4-video"), nil)
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.avi"), "avi")

    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.audio"), nil)
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.mp3"), "mp3")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.mpeg-4-audio"), "mp4")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("com.apple.protected-mpeg-4-audio"), "m4p")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.aiff-audio"), "aiff")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("com.microsoft.waveform-audio"), "wav")
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("public.midi-audio"), "midi")

    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier(""), nil)
    XCTAssertEqual(UTType.ky_getFileExtensionFromUniformTypeIdentifier("abc"), nil)
  }

  //
  // UTType.ky_getFileExtension()
  //
  func testGetFileExtension() async throws {
    XCTAssertEqual(UTType.image.ky_getFileExtension(), nil)
    XCTAssertEqual(UTType.jpeg.ky_getFileExtension(), "jpeg")
    XCTAssertEqual(UTType.tiff.ky_getFileExtension(), "tiff")
    XCTAssertEqual(UTType.gif.ky_getFileExtension(), "gif")
    XCTAssertEqual(UTType.png.ky_getFileExtension(), "png")
    XCTAssertEqual(UTType.icns.ky_getFileExtension(), "icns")
    XCTAssertEqual(UTType.bmp.ky_getFileExtension(), "bmp")
    XCTAssertEqual(UTType.ico.ky_getFileExtension(), "ico")
    XCTAssertEqual(UTType.rawImage.ky_getFileExtension(), nil)
    XCTAssertEqual(UTType.svg.ky_getFileExtension(), "svg")
    XCTAssertEqual(UTType.webP.ky_getFileExtension(), "webp")
    XCTAssertEqual(UTType.livePhoto.ky_getFileExtension(), nil)
    XCTAssertEqual(UTType.heif.ky_getFileExtension(), "heif")
    XCTAssertEqual(UTType.heic.ky_getFileExtension(), "heic")

    XCTAssertEqual(UTType.movie.ky_getFileExtension(), nil)
    XCTAssertEqual(UTType.video.ky_getFileExtension(), nil)
    XCTAssertEqual(UTType.quickTimeMovie.ky_getFileExtension(), "mov")
    XCTAssertEqual(UTType.mpeg.ky_getFileExtension(), "mpg")
    XCTAssertEqual(UTType.mpeg2Video.ky_getFileExtension(), "m2v")
    XCTAssertEqual(UTType.mpeg2TransportStream.ky_getFileExtension(), "ts")
    XCTAssertEqual(UTType.mpeg4Movie.ky_getFileExtension(), "mp4")
    XCTAssertEqual(UTType.appleProtectedMPEG4Video.ky_getFileExtension(), nil)
    XCTAssertEqual(UTType.avi.ky_getFileExtension(), "avi")

    XCTAssertEqual(UTType.audio.ky_getFileExtension(), nil)
    XCTAssertEqual(UTType.mp3.ky_getFileExtension(), "mp3")
    XCTAssertEqual(UTType.mpeg4Audio.ky_getFileExtension(), "mp4")
    XCTAssertEqual(UTType.appleProtectedMPEG4Audio.ky_getFileExtension(), "m4p")
    XCTAssertEqual(UTType.aiff.ky_getFileExtension(), "aiff")
    XCTAssertEqual(UTType.wav.ky_getFileExtension(), "wav")
    XCTAssertEqual(UTType.midi.ky_getFileExtension(), "midi")
  }

  // MARK: - Tests - File Type Checking

  //
  // UTType.ky_isPhotoFileType()
  //
  func testIsPhotoFileType() throws {
    XCTAssertTrue(UTType.image.ky_isPhotoFileType())
    XCTAssertTrue(UTType.jpeg.ky_isPhotoFileType())
    XCTAssertTrue(UTType.tiff.ky_isPhotoFileType())
    XCTAssertTrue(UTType.gif.ky_isPhotoFileType())
    XCTAssertTrue(UTType.png.ky_isPhotoFileType())
    XCTAssertTrue(UTType.icns.ky_isPhotoFileType())
    XCTAssertTrue(UTType.bmp.ky_isPhotoFileType())
    XCTAssertTrue(UTType.ico.ky_isPhotoFileType())
    XCTAssertTrue(UTType.rawImage.ky_isPhotoFileType())
    XCTAssertTrue(UTType.svg.ky_isPhotoFileType())
    XCTAssertTrue(UTType.webP.ky_isPhotoFileType())
    // XCTAssertTrue(UTType.livePhoto.ky_isPhotoFileType()) // TODO: Handle Live Photo
    XCTAssertTrue(UTType.heif.ky_isPhotoFileType())
    XCTAssertTrue(UTType.heic.ky_isPhotoFileType())
  }

  //
  // UTType.ky_isVideoFileType()
  //
  func testIsVideoFileType() throws {
    XCTAssertTrue(UTType.movie.ky_isVideoFileType())
    XCTAssertTrue(UTType.video.ky_isVideoFileType())
    XCTAssertTrue(UTType.quickTimeMovie.ky_isVideoFileType())
    XCTAssertTrue(UTType.mpeg.ky_isVideoFileType())
    XCTAssertTrue(UTType.mpeg2Video.ky_isVideoFileType())
    XCTAssertTrue(UTType.mpeg2TransportStream.ky_isVideoFileType())
    XCTAssertTrue(UTType.mpeg4Movie.ky_isVideoFileType())
    XCTAssertTrue(UTType.appleProtectedMPEG4Video.ky_isVideoFileType())
    XCTAssertTrue(UTType.avi.ky_isVideoFileType())
  }

  //
  // UTType.ky_isAudioFileType()
  //
  func testIsAudioFileType() throws {
    XCTAssertTrue(UTType.audio.ky_isAudioFileType())
    XCTAssertTrue(UTType.mp3.ky_isAudioFileType())
    XCTAssertTrue(UTType.mpeg4Audio.ky_isAudioFileType())
    XCTAssertTrue(UTType.appleProtectedMPEG4Audio.ky_isAudioFileType())
    XCTAssertTrue(UTType.aiff.ky_isAudioFileType())
    XCTAssertTrue(UTType.wav.ky_isAudioFileType())
    XCTAssertTrue(UTType.midi.ky_isAudioFileType())
  }
}
