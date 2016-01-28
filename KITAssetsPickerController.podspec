Pod::Spec.new do |spec|
  spec.name                  = 'KITAssetsPickerController'
  spec.version               = '1.0.5'
  spec.summary               = 'iOS control that allows picking multiple photos from custom data sources.'

  spec.description           = <<-DESC
                               KITAssetsPickerController is an iOS controller that allows picking
                               multiple photos from custom data sources..
                               The usage and look-and-feel just similar to UIImagePickerController.
                               It uses **ARC**.
                               DESC

  spec.homepage              = 'https://github.com/OceanLabs/KITAssetsPickerController'
  spec.license               = { :type => 'MIT', :file => 'LICENSE' }
  spec.author                = { 'Kostas Karayannis' => 'kkarayannis@gmail.com' }
  spec.social_media_url      = 'https://twitter.com/kkarayannis'
  spec.platform              = :ios, '7.0'
  spec.ios.deployment_target = '7.0'
  spec.source                = { :git => 'https://github.com/Oceanlabs/KITAssetsPickerController.git', :tag => '1.0.5' }
  spec.public_header_files   = 'KITAssetsPickerController/*.h'
  spec.source_files          = 'KITAssetsPickerController/**/*.{h,m}'
  spec.resource_bundles      = { 'KITAssetsPickerController' => ['KITAssetsPickerController/Resources/KITAssetsPicker.xcassets/*/*.png', 'KITAssetsPickerController/Resources/*.lproj'] }
  spec.requires_arc          = true
  spec.dependency            'PureLayout', '~> 3.0.0'
end
