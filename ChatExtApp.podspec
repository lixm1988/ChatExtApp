Pod::Spec.new do |s|
    s.name             = 'ChatExtApp'
    s.version          = '0.1.0'
    s.summary          = 'CloudClass Chat Ext App'
    s.description      = <<-DESC
        ‘灵动课堂聊天插件.’
    DESC
    s.homepage = 'https://www.easemob.com'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'easemob' => 'dev@easemob.com' }
    s.source           = { :git => 'https://XXX/.git', :tag => s.version.to_s }
    s.frameworks = 'UIKit'
    s.libraries = 'stdc++'
    s.ios.deployment_target = '9.0'
    s.source_files = 'ChatExtApp/**/*.{h,m}'
    s.public_header_files = [
      'ChatExtApp/ChatExtApp.h',
    ]
    s.resources = 'ChatExtApp/ChatExtApp.bundle'
    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES','EXCLUDED_ARCHS[sdk=iphonesimulator*]'=>'i386,arm64','VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
    s.dependency 'Masonry'
    s.dependency 'HyphenateChat'
    s.dependency 'SDWebImage'
    s.dependency 'BarrageRenderer'
    s.dependency 'WHToast'
    s.dependency 'AgoraExtApp'
end
