# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

use_frameworks!
workspace 'AEPAssurance'
project 'AEPAssurance.xcodeproj'

pod 'SwiftLint', '0.44.0'

target 'AEPAssurance' do
  pod 'AEPCore'
  pod 'AEPServices'
end

target 'UnitTests' do
  pod 'AEPCore'
  pod 'AEPServices'
end

target 'TestApp' do
  pod 'AEPCore'
  pod 'AEPServices'
  pod 'AEPLifecycle'
  pod 'AEPIdentity'
  pod 'AEPSignal'
  pod 'AEPEdge'
  pod 'AEPEdgeConsent'
  pod 'AEPEdgeIdentity'
  pod 'AEPUserProfile'
  pod 'AEPTarget'
  pod 'AEPAnalytics'
  pod 'AEPPlaces'
  #pod 'AEPOptimize', :git => 'https://github.com/adobe/aepsdk-optimize-ios.git', :branch => 'dev'
  pod 'AEPMessaging', :git => 'https://github.com/adobe/aepsdk-messaging-ios.git', :branch => 'staging'
end

target 'TestAppObjC' do
  pod 'AEPCore'
  pod 'AEPServices'
  pod 'AEPLifecycle'
  pod 'AEPIdentity'
  pod 'AEPSignal'
  pod 'AEPEdge'
  pod 'AEPEdgeConsent'
  pod 'AEPEdgeIdentity'
  pod 'AEPUserProfile'
  pod 'AEPTarget'
  pod 'AEPAnalytics'
  pod 'AEPPlaces'
end
