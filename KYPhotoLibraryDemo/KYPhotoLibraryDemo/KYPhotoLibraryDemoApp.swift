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

  static let docURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  static let archivesFolderURL: URL = docURL.appendingPathComponent("archives")

  @State private var selectedTab: DemoAssetType = .photo

  // MARK: - Init

  init() {
    NSLog("App Document Directory: \(KYPhotoLibraryDemoApp.docURL)")
  }

  var body: some Scene {
    WindowGroup {
      TabView(selection: $selectedTab) {
        _view(for: .archive)
        _view(for: .photo)
        _view(for: .video)
      }
    }
  }

  private func _view(for type: DemoAssetType) -> some View {
    NavigationView {
      if type == .archive {
        ArchivesView()
      } else {
        AssetsView(for: type)
      }
    }
    .navigationViewStyle(.stack)
    .tabItem {
      Label(type.tabText, systemImage: type.tabIconName)
    }
    .tag(type)
  }
}
