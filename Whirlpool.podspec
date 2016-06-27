Pod::Spec.new do |s|
 
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.name = "Whirlpool"
  s.summary = "Whirlpool is an image processing library."
  s.requires_arc = true
  s.version = "1.0.5"
  s.license = { :type => "MIT", :file => "LICENSE.md" }
  s.author = { "[Andrew Aquino]" => "[andrew@totemv.com]" }
  s.homepage = 'http://totemv.com/drewkiino'
  s.framework = "UIKit"
  s.source = { :git => 'https://github.com/DrewKiino/Whirlpool.git', :tag => 'master' }

  s.dependency 'Storm'
  s.dependency 'AsyncSwift'
  s.dependency 'SDWebImage'
  # s.dependency 'Alamofire', '3.2.1'

  s.source_files = "Whirlpool/Source/*.{swift}"

end