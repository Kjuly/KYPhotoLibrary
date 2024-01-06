//
//  DemoImagePicker.swift
//  KYPhotoLibraryDemo
//
//  Created by Kjuly on 6/1/2024.
//  Copyright © 2024 Kaijie Yu. All rights reserved.
//

import SwiftUI
import UIKit

struct DemoImagePicker: UIViewControllerRepresentable {

  private var sourceType: UIImagePickerController.SourceType = .photoLibrary
  private var didFinishPicking: ((_ pickedImage: UIImage) -> Void)

  // MARK: - Init

  init(
    for sourceType: UIImagePickerController.SourceType,
    didFinishPicking: @escaping (_ pickedImage: UIImage) -> Void
  ) {
    self.sourceType = sourceType
    self.didFinishPicking = didFinishPicking
  }

  // MARK: - UIViewControllerRepresentable

  func makeUIViewController(context: UIViewControllerRepresentableContext<DemoImagePicker>) -> UIImagePickerController {
    let controller = UIImagePickerController()
    controller.allowsEditing = false
    controller.sourceType = self.sourceType
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

    private var didFinishPicking: ((_ pickedImage: UIImage) -> Void)

    init(didFinishPicking: @escaping (_ pickedImage: UIImage) -> Void) {
      self.didFinishPicking = didFinishPicking
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
      if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        self.didFinishPicking(image)
      }
    }
  }
}
