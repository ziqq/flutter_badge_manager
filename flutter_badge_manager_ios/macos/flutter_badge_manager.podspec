Pod::Spec.new do |s|
  s.name             = 'flutter_badge_manager'
  s.version          = '0.0.1'
  s.summary          = 'Plugin to update the app badge on the launcher (both for Android, iOS and macOS)'
  s.description      = <<-DESC
  Plugin to update the app badge on the launcher (both for Android, iOS and macOS)
                       DESC
  s.homepage         = 'https://github.com/ziqq/flutter_badge_manager'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'Anton Ustinoff'
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'FlutterMacOS'

  s.platform = :osx
  s.osx.deployment_target = '10.11'
end