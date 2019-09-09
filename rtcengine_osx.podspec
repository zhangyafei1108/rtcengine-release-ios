Pod::Spec.new do |ss|
ss.name             = 'RTCEngine_osx'
ss.version          = '1.0.1'
ss.summary          = 'client osx  realtime audio/video'


ss.description      = <<-DESC
client osx  realtime audio/video
DESC

ss.homepage         = 'xxxxx'
#ss.license          = { :type => 'MIT' }
ss.author           = { 'zhangyf' => 'xxxxx' }
ss.source           = { :git => 'https://git.100tal.com/wangxiao_yunpingtai_rtc/rtcengine-ios-release.git', :tag => ss.version.to_s }

ss.preserve_paths = 'RTCEngine_osx.framework'
#s.vendored_libraries = 'RTCEngine_osx.framework'
ss.vendored_frameworks = 'RTCEngine_osx.framework'


#ss.framework = 'osx'

#ss.osx.framework = 'Accelerate', 'SystemConfiguration','CoreWLAN', 'Foundation', 'CoreAudio', 'CoreMedia', 'VideoToolbox', 'AudioToolbox', 'CFNetwork', 'CoreGraphics', 'CoreVideo'
ss.libraries = 'c', 'stdc++'
ss.requires_arc = true
ss.dependency  'AFNetworking'
ss.dependency  'AgoraRtcEngine_macOS','~> 2.2.0.0'
ss.dependency  'JWT'

end
