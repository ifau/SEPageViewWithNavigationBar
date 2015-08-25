Pod::Spec.new do |s|
  s.name         = "SEPageViewWithNavigationBar"
  s.version      = "1.0.0"
  s.summary      = "UIPageViewController which changes navigation bar title during the swipe pages, like in Twitter app."
  s.homepage     = "https://github.com/ifau/SEPageViewWithNavigationBar"
  s.license      = { :type => "MIT" }
  s.author       = { "Seliverstov Evgeney" => "ifau@me.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/ifau/SEPageViewWithNavigationBar.git", :tag => "1.0.0" }
  s.source_files = "*.swift"
  s.framework    = "UIKit"
  s.requires_arc = true
end