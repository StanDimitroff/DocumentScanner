Pod::Spec.new do |s|
  s.name             = 'DocumentScanner'
  s.version          = '1.0.4'
  s.summary          = 'Simple documents scanner using Vision'

  s.description      = <<-DESC
    DocumentScanner is based on rectangle detection, crops region of interest and exports UIImage
                       DESC

  s.homepage         = 'https://github.com/StanDimitroff/DocumentScanner'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'StanDimitroff' => 'standimitroff@gmail.com' }
  s.source           = { :git => 'https://github.com/StanDimitroff/DocumentScanner.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/standimitroff'

  s.ios.deployment_target = '10.0'

  s.source_files = 'DocumentScanner/Source/*.swift'

  s.resource_bundles = {
  'DocumentScanner' => [
      'DocumentScanner/Resources/*.xib',
      'DocumentScanner/Assets/*.png'
    ]
  }

end
