# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

platform :osx, "10.15"

target 'MasterAPI' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MasterAPI
  pod 'NSColor-HexString', '~> 1.0'
  # pod 'ZKTextField', '~> 0.0'
  pod 'SocketRocket'
  pod 'SBJson', '~> 5.0'
  pod 'DZReadability', '~> 0.2'
  pod 'JNWAnimatableWindow', '~> 0.5'
  pod 'IGFastImage', '~> 2.0'
  pod 'DBPrefsWindowController', '~> 0.0'
  pod 'DCOAboutWindow', '~> 0.2'
  pod 'DragDropImageView', '~> 1.0'
  # pod 'NSString+RMURLEncoding', '~> 0.1' - removed by it's author on github
  pod 'NSHash', '~> 1.1'
  pod 'NACrypto', '~> 1.1'
  pod 'IGDigest', '~> 1.1'
  pod 'OGCryptoHash', '~> 0.2'
  pod 'SYFlatButton', '~> 1.3'
  pod 'DCTextEngine', '~> 0.1'
  pod 'PocketSVG', '~> 2.2'
  pod 'FontAwesomeIconFactory', '~> 3.0'
  pod 'RBBAnimation', '~> 0.4'
  # pod 'SDWebImage', '~> 5.4.0' - new methods must be learned before using
  pod 'SDWebImage', '~> 4.2'
  pod 'Vivid', '~> 0.9'
  pod 'IRFAutoCompletionKit', '~> 0.2'
  pod 'YUCIImageView', '~> 0.4'
  pod 'HTMLReader', '~> 2.1'
  pod 'BOString', '~> 0.10'
  pod 'MetalPetal', '~> 1.6'

end
#for suppressing warning from every pod
=begin
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
      end
    end
  end
=end