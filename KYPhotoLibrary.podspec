Pod::Spec.new do |spec|
  spec.name         = "KYPhotoLibrary"
  spec.version      = "2.1.1"
  spec.summary      = "A Photo Library extension to save images or video to custom photo albums."
  spec.license      = "MIT"
  spec.source       = { :git => "https://github.com/Kjuly/KYPhotoLibrary.git", :tag => spec.version.to_s }
  spec.homepage     = "https://github.com/Kjuly/KYPhotoLibrary"

  spec.author             = { "Kjuly" => "dev@kjuly.com" }
  spec.social_media_url   = "https://twitter.com/kJulYu"

  spec.ios.deployment_target = "15.5"

  spec.swift_version = '5.0'

  spec.source_files  = "KYPhotoLibrary"

  spec.requires_arc = true
end
