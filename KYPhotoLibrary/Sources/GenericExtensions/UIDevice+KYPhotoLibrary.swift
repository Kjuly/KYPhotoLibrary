//
//  UIDevice+KYPhotoLibrary.swift
//  KYPhotoLibrary
//
//  Created by Kjuly on 19/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit

extension UIDevice {
  static var ky_isCompact: Bool = (UIDevice.current.userInterfaceIdiom == .phone)
}
#endif
