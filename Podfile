# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

target 'TRTCSimpleDemo' do
  # Comment the next line if you don't want to use dynamic frameworks

  pod 'TXLiteAVSDK_TRTC'
  pod 'SVProgressHUD'
  pod 'Masonry'
  pod 'AFNetworking'
  #pod 'Nama', '~> 7.3.0'
  
  
  # Pods for TRTCSimpleDemo
  

end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
            config.build_settings['ENABLE_BITCODE'] = 'NO'
         end
    end
  end
end
