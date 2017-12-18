#
# Be sure to run `pod lib lint DocumentScanner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DocumentScanner'
  s.version          = '1.0.1'
  s.summary          = 'Simple documents scanner using Vision'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
DocumentScanner is based on rectangle detection, crops region of interest and exports UIImage
                       DESC

  s.homepage         = 'https://github.com/StanDimitroff/DocumentScanner'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'StanDimitroff' => 'standimitroff@gmail.com' }
  s.source           = { :git => 'https://github.com/StanDimitroff/DocumentScanner.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'DocumentScanner/Classes/**/*.swift'

  s.resource_bundles = {
  'DocumentScanner' => [
      'DocumentScanner/Resources/**/*.xib',
      'DocumentScanner/Assets/**/*.png'
    ]
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
