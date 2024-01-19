//
//  TimeInterval+KYPhotoLibrary.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 19/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation
import CoreMedia

extension TimeInterval {

  //
  // You frequently use a timescale of 600, because this is a multiple of several commonly used
  //   frame rates: 24 fps for film, 30 fps for NTSC (used for TV in North America and Japan),
  //   and 25 fps for PAL (used for TV in Europe).
  //
  // REF:
  // - https://gist.github.com/wangchauyan/e18a974fca99d068251c4c33b4a1c010
  // - https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/06_MediaRepresentations.html
  //
  var ky_toCMTime: CMTime {
    return CMTimeMakeWithSeconds(self, preferredTimescale: Int32(NSEC_PER_SEC))
  }
}
