# rtcengine-ios-release

例子说明
cd RTCStream-ios
pod install
打开  RTCStream-ios.xcworkspace 执行即

使用说明：（动态库framework方式提供，基于声网agora:2.4.0/agora:2.2.0版本)

1、在你工程里面可以集成使用
     位置：根目录下
       ios：   RTCEngine.framework
       macox：RTCEngine.framework
2、pod方式安装使用
Podfile:
ios use:
pod 'RTCEngine', :git => 'https://github.com/zhangyafei1108/rtcengine-release-ios.git'


3、你的真是声网的id
    _Appsecret = @"";
    _Appid = @""
