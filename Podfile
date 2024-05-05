# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Rabble Hub' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Rabble Hub
  pod 'DialCountries'
  pod 'EliteOTPField'
  pod 'IQKeyboardManagerSwift'
  pod 'QRCodeReader.swift', '~> 10.1.0'
  
  post_install do |installer|
      installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
              end
          end
      end
  end

  target 'Rabble HubTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Rabble HubUITests' do
    # Pods for testing
  end

end
