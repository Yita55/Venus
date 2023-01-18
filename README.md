# Venus (Venus-iOS)

Venus client app for iOS.

## Requirement

* [Xcode](https://itunes.apple.com/tw/app/xcode/id497799835) 8.3+
* [Homebrew](http://brew.sh/)
* [CocoaPods](https://cocoapods.org/) 1.2.1
* [Carthage](https://github.com/Carthage/Carthage) 0.20.1

## Development

### Swift Version

Swift 3.1

### Coding Style

TODO

## Installation

What tools need to install first.

### 1. Homebrew

Package manager for OS X.

```sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
Paste that at a Terminal prompt.

### 2. CocoaPods

CocoaPods is a dependency manager for Swift and Objective-C Cocoa projects.

```sh
brew install cocoapods
```

### 3. Carthage

Carthage is intended to be the simplest way to add frameworks to your Cocoa application.

```sh
brew install carthage
```

### 4. Check out source code

Check out source code.

```sh
# If your projects will check out in projects.
cd ~/projects
git clone http://github.com/xxx/venus-ios.git
# Input your credential username/password on github.
```
Project location will be here `~/projects/Venus/`

## Build Dependencies

Only build dependencies if you added new dependencies or first build.

> Add new dependencies on Podfile and Cartfile.  
> Study CocoaPods and Carthage documentation to see how to work.

```sh
cd ~/projects/Venus/
# Build and install frameworks by CocoaPods
pod install
# pod install --repo-update
# Checkout, build frameworks by Carthage
# carthage bootstrap --platform ios --no-use-binaries
```

## Use Workspace

Using `Venus.xcworkspace` to develop and build, because we use CocoaPods.

## Used Frameworks (Migrated Swift 3)

### Dependencies from CocoaPods

```sh
# Podfile
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
```
