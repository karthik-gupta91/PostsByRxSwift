# Uncomment the next line to define a global platform for your project

platform :ios, '14.0'

target 'postsByRxSwift' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'Alamofire'
  pod 'PKHUD', '~> 5.0'

  # Pods for postsByRxSwift

  target 'postsByRxSwiftTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'postsByRxSwiftUITests' do
    # Pods for testing
  end
  
  post_install do |installer|
      installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
              end
          end
      end
  end
  
end
