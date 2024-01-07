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
      TabView {
        _view(for: .photos)
        _view(for: .videos)
      }
    }
  }

  @ViewBuilder
  private func _view(for type: DemoMediaType) -> some View {
    NavigationView {
      ContentView(for: type)
    }
    .navigationViewStyle(.stack)
    .tabItem {
      Label(type.tabText, systemImage: type.tabIconName)
    }
  }
}
