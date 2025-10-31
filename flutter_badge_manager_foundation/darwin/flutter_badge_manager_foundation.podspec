#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_badge_manager_foundation'
  s.version          = '0.1.0'
  s.summary          = 'iOS and macOS implementation of the flutter_badge_manager plugin'
  s.description      = <<-DESC
  Plugin to update the app badge on the app icon.
                       DESC
  s.homepage         = 'https://github.com/ziqq/flutter_badge_manager/flutter_badge_manager_foundation'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = 'Anton Ustinoff'

  # Use local path (plugin shipped from local packages directory for Flutter). Remote :http not needed.
  s.source           = { :path => '.' }

  s.source_files        = 'flutter_badge_manager_foundation/Sources/flutter_badge_manager_foundation/**/*.swift'
  s.requires_arc = true

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'

  s.ios.frameworks = 'UserNotifications', 'UIKit'
  s.osx.frameworks = 'AppKit'

  s.swift_version = '5.0'
end

