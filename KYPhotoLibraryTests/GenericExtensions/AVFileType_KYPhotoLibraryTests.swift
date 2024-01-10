//
//  AVFileType_KYPhotoLibraryTests.swift
//  KYPhotoLibraryTests
//
//  Created by Kjuly on 8/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import XCTest
import AVFoundation
@testable import KYPhotoLibrary

final class AVFileType_KYPhotoLibraryTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  // MARK: - Tests - Creation

  //
  // static AVFileType.ky_fromFileExtension(_:)
  //
  func testCreationFromFileExtension() throws {
    XCTAssertEqual(AVFileType.ky_fromFileExtension("MOV"), .mov)
    XCTAssertEqual(AVFileType.ky_fromFileExtension("mov"), .mov)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("MP4"), .mp4)
    XCTAssertEqual(AVFileType.ky_fromFileExtension("mp4"), .mp4)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("m4v"), .m4v)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("m4a"), .m4a)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("3gp"), .mobile3GPP)
    XCTAssertEqual(AVFileType.ky_fromFileExtension("3gpp"), .mobile3GPP)
    XCTAssertEqual(AVFileType.ky_fromFileExtension("sdv"), .mobile3GPP)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("3g2"), .mobile3GPP2)
    XCTAssertEqual(AVFileType.ky_fromFileExtension("3gp2"), .mobile3GPP2)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("caf"), .caf)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("wav"), .wav)
    XCTAssertEqual(AVFileType.ky_fromFileExtension("wave"), .wav)
    XCTAssertEqual(AVFileType.ky_fromFileExtension("bwf"), .wav)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("aif"), .aiff)
    XCTAssertEqual(AVFileType.ky_fromFileExtension("aiff"), .aiff)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("aifc"), .aifc)
    // XCTAssertEqual(AVFileType.ky_fromFileExtension("cdda"), .aifc) // public.cdda-audio

    XCTAssertEqual(AVFileType.ky_fromFileExtension("amr"), .amr)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("mp3"), .mp3)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("au"), .au)
    XCTAssertEqual(AVFileType.ky_fromFileExtension("snd"), .au)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("ac3"), .ac3)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("eac3"), .eac3)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("jpg"), .jpg)
    XCTAssertEqual(AVFileType.ky_fromFileExtension("jpeg"), .jpg)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("dng"), .dng)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("heic"), .heic)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("avci"), .avci)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("heif"), .heif)

    XCTAssertEqual(AVFileType.ky_fromFileExtension("tiff"), .tif)
    XCTAssertEqual(AVFileType.ky_fromFileExtension("tif"), .tif)

    // if #available(iOS 17, *) {
    //   XCTAssertEqual(AVFileType.ky_fromFileExtension("ahap"), .AHAP)
    //   XCTAssertEqual(AVFileType.ky_fromFileExtension("AHAP"), .AHAP)
    // }

    //
    // Undefined but valid
    XCTAssertEqual(AVFileType.ky_fromFileExtension("png"), AVFileType("public.png"))
    XCTAssertEqual(AVFileType.ky_fromFileExtension("gif"), AVFileType("com.compuserve.gif"))

    //
    // Invalid
    XCTAssertNil(AVFileType.ky_fromFileExtension(""))
    XCTAssertNil(AVFileType.ky_fromFileExtension(".mp4"))
    XCTAssertNil(AVFileType.ky_fromFileExtension(".mov"))
  }
}
