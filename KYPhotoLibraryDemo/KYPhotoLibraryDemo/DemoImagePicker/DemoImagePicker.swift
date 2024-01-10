//
//  DemoImagePicker.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 6/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DemoImagePicker: UIViewControllerRepresentable {

  typealias Completion = (_ image: UIImage?, _ videoURL: URL?) -> Void

  private var type: DemoAssetType
  private var didFinishPicking: Completion

  // MARK: - Init

  init(for type: DemoAssetType, didFinishPicking: @escaping Completion) {
    self.type = type
    self.didFinishPicking = didFinishPicking
  }

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(context: UIViewControllerRepresentableContext<DemoImagePicker>) -> UIImagePickerController {
    let controller = UIImagePickerController()
    controller.allowsEditing = false
    controller.sourceType = .camera
    controller.mediaTypes = (self.type == .video ? [UTType.movie.identifier] : [UTType.image.identifier])
    controller.delegate = context.coordinator
    return controller
  }

  func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<DemoImagePicker>) {

  }

  func makeCoordinator() -> Coordinator {
    Coordinator(didFinishPicking: self.didFinishPicking)
  }

  // MARK: - Coordinator

  final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var didFinishPicking: Completion

    init(didFinishPicking: @escaping Completion) {
      self.didFinishPicking = didFinishPicking
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
      guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String else {
        return
      }

      if mediaType == UTType.image.identifier {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
          return
        }
        self.didFinishPicking(image, nil)

      } else if mediaType == UTType.movie.identifier {
        guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
          return
        }
        self.didFinishPicking(nil, videoURL)

      } else {
        self.didFinishPicking(nil, nil)
      }
    }
  }
}
