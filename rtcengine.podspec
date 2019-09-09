Pod::Spec.new do |s|
s.name             = 'RTCEngine'
s.version          = '1.0.14'
s.summary          = 'rtcEngine  realtime audio/video  as a service'
s.description      = <<-DESC
dotEngine realtime audio/video as a service
DESC
s.homepage         = 'xxxx'
s.license          = { :type => 'MIT' }
s.author           = { 'notedit' => 'notedit@gmail.com' }
s.source           = { :git => 'https://github.com/zhangyafei1108/rtcengine-release-ios.git', :tag => s.version.to_s }

#s.source_files =  'RTCEngine.framework/Headers/*.h'
#s.public_header_files = 'RTCEngine.framework/Headers/*.h'
s.preserve_paths = 'RTCEngine.framework'
#s.vendored_libraries = 'RTCEngine.framework'
s.vendored_frameworks = 'RTCEngine.framework'

s.ios.framework = 'Accelerate', 'SystemConfiguration','AudioToolbox', 'CoreGraphics', 'CoreMedia', 'AVFoundation', 'CoreML', 'VideoToolbox'
s.libraries = 'c', 'stdc++'
s.requires_arc = true
s.dependency  'AFNetworking'
s.dependency  'AgoraRtcEngine_iOS','~> 2.4.0.0'
s.dependency  'JWT'
end

