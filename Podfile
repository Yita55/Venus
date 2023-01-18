# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Venus' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Venus
  pod 'Charts'
  # pod 'iOSDFULibrary', '~> 3.0'
  pod 'Alamofire', '~> 4.4'
  pod 'SDCAlertView', '~> 7.1'
  pod 'KDCircularProgress'
  pod 'EZAlertController', '3.2'
  pod 'SwiftProgressHUD'
  pod 'MBCircularProgressBar'
  pod 'Bitter'
  pod 'RealmSwift'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
