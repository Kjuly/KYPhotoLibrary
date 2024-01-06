//
//  KYPhotoLibraryDemoApp.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 6/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI

@main
struct KYPhotoLibraryDemoApp: App {

  static let customPhotoAlbumName = "KYPhotoLibrary Demo"

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
      .navigationViewStyle(.stack)
    }
  }
}
