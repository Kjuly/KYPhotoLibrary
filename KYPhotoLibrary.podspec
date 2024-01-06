Pod::Spec.new do |spec|
  spec.name         = "KYPhotoLibrary"
  spec.version      = "1.3.0"
  spec.summary      = "A Photo Library extension for saving images or videos to custom photo albums."
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
