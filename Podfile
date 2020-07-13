# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
use_frameworks!

project 'PlasticBullet.xcodeproj'

target 'PlasticBullet' do
    pod 'XMCircleType', '1.1.1'
    pod 'Crashlytics', '~> 3.7.0'
    pod 'SwiftyMarkdown', '~> 0.2'
end



post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end