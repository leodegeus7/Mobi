source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'Mobi-Swift-3.0' do
pod 'Alamofire', '~> 3.4'
pod 'SwiftyJSON'
pod 'RealmSwift' 
pod 'SideMenu'
pod "ARNTransitionAnimator"
pod ‘Firebase/Core’
pod ‘Firebase/Database’
pod ‘Firebase/Auth’
pod 'Fabric'
pod 'TwitterKit'
pod 'TwitterCore'
pod 'PullToRefresh'
pod 'ChameleonFramework/Swift'
pod 'Kingfisher', '~> 2.5’
pod 'FirebaseUI/Auth'
pod 'FirebaseUI/Database’
pod 'FirebaseUI/Facebook’
pod 'Eureka', '~> 1.7.0’
pod 'Cosmos', '~> 1.2’
pod 'ImageViewer’, '~> 2.0’
pod ‘MWFeedParser’
pod ‘FirebaseUI/Twitter‘
pod 'Firebase/Messaging'
pod ‘Firebase/Crash’
pod ‘PocketSVG‘
end 
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end