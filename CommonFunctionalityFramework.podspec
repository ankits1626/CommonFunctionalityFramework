#
#  Be sure to run `pod spec lint CommonFunctionalityFramework.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "CommonFunctionalityFramework"
  spec.version      = "1.0"
  spec.summary      = "Common functionality for Rewardz mobile apps."
  spec.description      = "Common functionality for Rewardz mobile apps."
  spec.platform      = :ios,"10.0"
  spec.homepage      = "http://cerrapoints.com"
  spec.license      = "MIT"
spec.author             = { "Rewardz" => "ankit._seeking_job@yahoo.co.in" }
 spec.source       = { :git => "https://github.com/ankits1626/CommonFunctionalityFramework" }
spec.source_files  = "CommonFunctionalityFramework"
spec.exclude_files = "Classes/Exclude"
spec.swift_version = "5.0"

end
