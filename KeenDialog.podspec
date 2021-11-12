
Pod::Spec.new do |s|
  s.name          = 'KeenDialog'
  s.version       = '1.0.0'
  s.summary       = '一款非常简便轻巧的对话弹窗，对业务零耦合，可自由定制化属性参数'
  s.homepage      = 'https://github.com/chongzone/KeenDialog'
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author        = { 'chongzone' => 'chongzone@163.com' }
  
  s.requires_arc  = true
  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'
  s.source = { :git => 'https://github.com/chongzone/KeenDialog.git', :tag => s.version }
  
  s.source_files = 'KeenDialog/Classes/**/*'
  s.resource_bundles = {
    'KeenDialog' => ['KeenDialog/Assets/**/*']
  }
  s.dependency 'SnapKit'
  
end
