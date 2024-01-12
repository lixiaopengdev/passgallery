platform :ios, '13.0'

use_frameworks!

target "passGallery" do
    pod 'Masonry'
    pod 'Google-Mobile-Ads-SDK'
    pod 'ZYQAssetPickerController',  '~> 1.2.0'
    pod 'KNPhotoBrowser'
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                config.build_settings['ENABLE_BITCODE'] = 'NO'
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
                  xcconfig_path = config.base_configuration_reference.real_path
                  xcconfig = File.read(xcconfig_path)
                  xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
                  File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }

               end
          end
   end
end


