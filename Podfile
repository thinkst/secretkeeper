# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
workspace ''

target 'SecretKeeper' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Realm', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', submodules: true
  pod 'RealmSwift', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', submodules: true
  pod 'CryptoSwift', :git => "https://github.com/krzyzanowskim/CryptoSwift", :branch => "master"

  # Pods for SecretKeeper

  target 'SecretKeeperTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
