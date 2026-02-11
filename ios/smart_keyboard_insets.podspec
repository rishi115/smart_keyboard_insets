#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint smart_keyboard_insets.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'smart_keyboard_insets'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for accurate keyboard height and safe area detection.'
  s.description      = <<-DESC
A Flutter plugin that provides accurate keyboard height and safe area bottom inset detection on iOS.
                       DESC
  s.homepage         = 'https://github.com/rishi115/smart_keyboard_insets'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'rishi115' => 'rishidevare051@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version    = '5.0'
end
