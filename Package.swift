// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "KYPhotoLibrary",
  platforms: [
    .iOS("15.5"),
  ],
  products: [
    .library(
      name: "KYPhotoLibrary",
      targets: [
        "KYPhotoLibrary",
      ]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "KYPhotoLibrary",
      dependencies: [
      ],
      path: "KYPhotoLibrary/Sources"),
    .testTarget(
      name: "KYPhotoLibraryTests",
      dependencies: [
        "KYPhotoLibrary",
      ],
      path: "KYPhotoLibraryTests"),
  ]
)
