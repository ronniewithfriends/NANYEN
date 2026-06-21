Pod::Spec.new do |s|
  s.name           = 'WidgetBridge'
  s.version        = '1.0.0'
  s.summary        = 'Reads the NANYEN widget App Group inbox into React Native'
  s.description    = 'Bridges the App Group shared storage written by the home-screen widget to JS.'
  s.author         = ''
  s.homepage       = 'https://github.com/ronniewithfriends/NANYEN'
  s.platforms      = { :ios => '15.1' }
  s.source         = { git: '' }
  s.static_framework = true

  s.dependency 'ExpoModulesCore'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_COMPILATION_MODE' => 'wholemodule'
  }

  s.source_files = "**/*.{h,m,swift}"
end
