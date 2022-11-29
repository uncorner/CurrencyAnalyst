# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
platform :ios, '12.0'

# Instead of specifying a deployment target in pod post install, you can delete the pod deployment target for each pod, which causes the deployment target to be inherited from the Podfile.
# need to run pod install for the effect to take place.
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end

target 'CurrencyAnalystCocoa' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CurrencyAnalystCocoa
  pod 'SwiftSoup', '2.3.3'
  pod 'Alamofire', '5.4.3'
  pod 'RxSwift', '6.2.0'
  pod 'RxRelay', '6.2.0'
  pod 'RxCocoa', '6.2.0'
  pod 'RxDataSources', '5.0.0'
  pod 'RxAlamofire', '6.1.1'
  pod 'GoogleMaps', '5.1.0'
  pod 'GooglePlaces', '5.0.0'
  pod 'SwiftEntryKit', '1.2.7'
  pod 'Action', '5.0.0'

  target 'CurrencyAnalystCocoaTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
