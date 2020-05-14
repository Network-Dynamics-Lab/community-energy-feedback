source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'

use_modular_headers!

target 'Community Energy Feedback' do
	pod 'CocoaLumberjack/Swift'

    pod 'ARCL'

    pod 'Charts'


end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
        end
    end
end


