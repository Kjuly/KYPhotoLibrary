//
//  UTType_KYPhotoLibraryTests.swift
//  KYPhotoLibraryTests
//
//  Created by Kjuly on 8/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import XCTest
import UniformTypeIdentifiers
@testable import KYPhotoLibrary

final class UTType_KYPhotoLibraryTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

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
