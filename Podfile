# Uncomment the next line to define a global platform for your project
# source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
inhibit_all_warnings!

def sourcePod
  pod 'AgoraExtApp', :path => '../CloudClass-iOS/AgoraEduSDK/Modules/AgoraExtApp/AgoraExtApp.podspec'
  pod 'AgoraUIBaseViews', :path => '../CloudClass-iOS/AgoraEduSDK/Modules/AgoraUIBaseViews/AgoraUIBaseViews.podspec'
end

target 'ChatExtApp' do
  use_frameworks!
  pod 'HyphenateChat'
  pod 'BarrageRenderer'
  pod 'SDWebImage'
  pod 'Masonry'
  pod 'WHToast'
  sourcePod
end
