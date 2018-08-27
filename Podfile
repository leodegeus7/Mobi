source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'Mobi-Swift-3.0' do
    pod 'Alamofire', '~> 4.0'
    pod 'RealmSwift', '~> 2.8.0'
    pod 'SwiftyJSON', '~> 3.1.4'
    pod 'SideMenu', '~> 2.3.4'
    pod 'ARNTransitionAnimator', '~> 3.0.0'
    pod 'Fabric'
    pod 'PullToRefresh'
    pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
    pod 'Kingfisher', '~> 3.13.1’
    pod 'Firebase/Core’, '~> 3.0’
    pod 'Firebase/Auth’, '~> 3.0’
    pod 'Firebase/Database’, '~> 3.0’
    pod 'Firebase/Messaging’, '~> 3.0’
    pod 'Firebase/Crash’, '~> 3.0’
    pod 'FirebaseUI/Database’, '~> 3.0’
    pod 'FirebaseUI/Facebook’, '~> 3.0’
    pod 'FirebaseUI/Auth’, '~> 3.0’
    pod 'ImageViewer’, '~> 4.0’
    pod 'Eureka', '~> 3.1.0’
    pod 'Cosmos', '~> 9.0'
    pod 'MWFeedParser'
    pod 'PocketSVG'
    pod "FBSDKLoginKit", "4.24.0"
    pod "FBSDKCoreKit", "4.24.0"
end 
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
