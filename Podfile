# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

workspace 'GRDBDemo'

project 'GRDBDemo'

def installationSettings
    use_frameworks!
    inhibit_all_warnings!
end

def commonPods
    pod 'AWSS3', '= 2.12.7'
    # GRDB with SQLCipher 4
    pod 'GRDB.swift/SQLCipher', '= 4.11.0'
    pod 'SQLCipher', '= 4.3.0'
    pod 'CryptoSwift', '= 0.13.0'
end

target 'GRDBDemo' do
    project 'GRDBDemo'
    installationSettings
    commonPods
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
    end
end
