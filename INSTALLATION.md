# Installation

## [Swift Package Manager](https://swift.org/package-manager)

#### Option 1: Use Package.swift

Edit `Package.swift` to add the lib as a dependency:
```swift
dependencies: [
  .package(url: "https://github.com/Kjuly/KYPhotoLibrary.git", .upToNextMajor(from: "2.0"))
]
```
For a detailed guide, read Apple's developer doc [Creating a standalone Swift package with Xcode](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode) and Swift's [Swift Package Manager](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html).

#### Option 2: Use Xcode Project

To add a package dependency to your Xcode project, select **File > Add Package Dependency** and enter the URL: `https://github.com/Kjuly/KYPhotoLibrary.git`.

For a detailed guide, read Apple's developer doc: [Adding package dependencies to your app](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).

## [CocoaPods](https://cocoapods.org)

1. Edit `Podfile` to add the dependency:
```ruby
# Integrating CocoaPods with an existing workspace requires one extra line in your Podfile.
# Remove it if not.
workspace 'YourWorkspace'

# Provide the platform info, iOS 16.0+ as an example here.
platform :ios, '16.0'

# Add package to your project target
target 'YourProjectTarget' do
  project 'Path/To/Your/YourProjectTarget.xcodeproj'

  pod 'KYPhotoLibrary', '~> 2.0'
end
```

2. Close your Xcode project and run commands below:
```bash
$ pod install
```

For a detailed guide, read CocoaPods's doc: [Using CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html).

> [!TIP]
> - Use `pod install` to install new pods in your project. Even if you already have a Podfile and ran pod install before; so even if you are just adding/removing pods to a project already using CocoaPods.
> - Use `pod update <PODNAME>` only when you want to update pods to a newer version.
>
> You can find a detailed explanation [here](https://guides.cocoapods.org/using/pod-install-vs-update.html).

## [Carthage](https://github.com/Carthage/Carthage)

1. Edit `Cartfile` to add the dependency:
```ruby
github "Kjuly/KYPhotoLibrary" ~> 2.0
```

2. Run the command in terminal:
```bash
$ carthage update --use-xcframeworks
```

3. Drag the built `KYPhotoLibrary.xcframework` from `Carthage/Build` to the "Frameworks, Libraries, and Embedded Content" section of your Xcode project.

> [!TIP]
> If you are using Carthage for an application, select "Embed & Sign", otherwise "Do Not Embed".

For a detailed guide, read Carthage's [Quick Start](https://github.com/Carthage/Carthage#quick-start).

> [!IMPORTANT]
> Carthage builds your dependencies and provides you with a binary framework, which defaults to a **Release** configuration. So if you want to print debug logs on the console, you need to run the command below. Xcode will update *.xcframework automatically if you've added them already.
> 
>     $ carthage update --use-xcframeworks --configuration Debug
>
> Once you're done debugging, just don't forget to switch it back to production:
>
>     $ carthage update --use-xcframeworks

## [Submodule](https://git-scm.com/docs/git-submodule)

If you don't want to use any of the above package managers, you can add packages to your project manually.

1. Run the commands in terminal:
```bash
$ cd path/to/your/root/project/directory
$ git submodule add https://github.com/Kjuly/KYPhotoLibrary.git Libs/KYPhotoLibrary
```

2. Open your project and add a reference to the source code folder: "KYPhotoLibrary/KYPhotoLibrary".

For a detailed guide about git submodule usage, read git's doc: [git-submodule](https://git-scm.com/docs/git-submodule).

