Pod::Spec.new do |spec|
  spec.name                  = 'KITAssetsPickerController'
  spec.version               = '3.1.0'
  spec.summary               = 'iOS control that allows picking multiple photos and videos from user\'s photo library.'

  spec.description           = <<-DESC
                               KITAssetsPickerController is an iOS controller that allows picking
                               multiple photos and videos from user's photo library.
                               The usage and look-and-feel just similar to UIImagePickerController.
                               It uses **ARC** and **Photos** frameworks.
                               DESC

  spec.homepage              = 'https://github.com/chiunam/KITAssetsPickerController'
  spec.screenshot            = 'https://raw.github.com/chiunam/KITAssetsPickerController/master/Screenshot.png'
  spec.license               = { :type => 'MIT', :file => 'LICENSE' }
  spec.author                = { 'Clement T' => 'chiunam@gmail.com' }
  spec.social_media_url      = 'https://twitter.com/chiunam'
  spec.platform              = :ios, '8.0'
  spec.ios.deployment_target = '8.0'
  spec.source                = { :git => 'https://github.com/chiunam/KITAssetsPickerController.git', :tag => 'v3.1.0' }
  spec.public_header_files   = 'KITAssetsPickerController/*.h'
  spec.source_files          = 'KITAssetsPickerController/**/*.{h,m}'
  spec.resource_bundles      = { 'KITAssetsPickerController' => ['KITAssetsPickerController/Resources/KITAssetsPicker.xcassets/*/*.png', 'KITAssetsPickerController/Resources/*.lproj'] }
  spec.ios.frameworks        = 'Photos'
  spec.requires_arc          = true
  spec.dependency            'PureLayout', '~> 3.0.0'
end
