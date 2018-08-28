source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'Mobi-Swift-3.0' do
    pod 'ARNTransitionAnimator', '~> 2.2.0'
    pod 'Alamofire', '~> 4.7'
    pod 'RealmSwift', '~> 3.0.0'
    pod 'SwiftyJSON', '~> 4.0.0'
    pod 'SideMenu', '~> 3.1'
    pod 'Fabric'
    pod 'PullToRefresh'
    pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
    pod 'Kingfisher', '~> 4.5.0’
    pod 'Firebase/Core’, '~> 4.0’
    pod 'Firebase/Auth’, '~> 4.0’
    pod 'Firebase/Database’, '~> 4.0’
    pod 'Firebase/Messaging’, '~> 4.0’
    pod 'Firebase/Crash’, '~> 4.0’
    pod 'FirebaseUI/Database’, '~> 4.0’
    pod 'FirebaseUI/Facebook’, '~> 4.0’
    pod 'FirebaseUI/Auth’, '~> 4.0’
    pod 'ImageViewer’, '~> 4.0’
    pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka.git', :branch => 'Swift-3.3'
    pod 'Cosmos', '~> 9.0'
    pod 'MWFeedParser'
    pod 'PocketSVG'
    pod "FBSDKLoginKit"
    pod "FBSDKCoreKit"
end 
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
