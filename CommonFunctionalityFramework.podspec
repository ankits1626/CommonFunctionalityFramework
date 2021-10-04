Pod::Spec.new do |spec|

  spec.name         = "CommonFunctionalityFramework"
  spec.version      = "0.0.7"
  spec.summary      = "CommonFunctionalityFramework"

  spec.description  = <<-DESC
Common Functionality framework for flab and cerra
                   DESC

  spec.homepage     = "https://github.com/ankits1626/CommonFunctionalityFramework"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Ankit Sachan" => "ankit@rewardz.sg" }

  spec.ios.deployment_target = "11.0"
  spec.swift_version = "4.2"

  spec.source        = { :git => "https://github.com/ankits1626/CommonFunctionalityFramework.git", :branch => "addedASChatView"}
  spec.source_files  = "CommonFunctionalityFramework/**/*.{h,m,swift}", 'CommonFunctionalityFramework/**/*.xcdatamodeld','CommonFunctionalityFramework/*.lproj/*.strings', 'CommonFunctionalityFramework/**/*.lproj/*.strings',"CommonFunctionalityFramework/**/*.{xib,storyboard}", 'CommonFunctionalityFramework/**/*.xcdatamodeld'
spec.resources = "CommonFunctionalityFramework/**/*.{png,jpg,jpeg}", "*.xcassets"
spec.resource_bundles = {'CommonFunctionalityFramework' => ['CommonFunctionalityFramework/**/*.xcdatamodeld']}
spec.framework    = 'CoreData'
  spec.dependency 'RewardzCommonComponents'
  spec.dependency 'KUIPopOver', '= 1.1.2'
  spec.dependency 'SimpleCheckbox'
  spec.dependency 'ActiveLabel'
  spec.dependency 'Loaf'
  spec.dependency 'FLAnimatedImage', '~> 1.0'
end
