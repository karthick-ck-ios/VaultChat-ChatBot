Pod::Spec.new do |s|
  s.name             = 'VaultChat'
  s.version          = '1.0.0'
  s.summary          = 'Intelligent Document Chat for Your Business.'
  s.description      = 'Transform your business documents into an interactive AI assistant. Upload your knowledge base and let VaultChat handle customer queries instantly.'
  s.homepage         = 'https://github.com/karthick-ck-ios/VaultChat'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Karthick' => 'arthickbe@gmail.com' }
  s.source           = { :git => 'https://github.com/karthick-ck-ios/VaultChat.git', :tag => s.version.to_s }

  s.platform         = :ios, '15.0'
  s.swift_version    = '5.0'

  s.source_files     = 'VaultChat/**/*.swift'
end
