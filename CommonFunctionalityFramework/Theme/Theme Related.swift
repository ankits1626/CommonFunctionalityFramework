//
//  FontApplied.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

extension UIFont{
    static var Title1 : UIFont{
        return UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    static var Body1 : UIFont{
        return UIFont.systemFont(ofSize: 11, weight: .regular)
    }
    
    static var Highlighter1 : UIFont{
        return UIFont.systemFont(ofSize: 10, weight: .bold)
    }
    
    static var Highlighter2 : UIFont{
        return UIFont.systemFont(ofSize: 13, weight: .bold)
    }
    
    static var Caption1 : UIFont{
        return UIFont.systemFont(ofSize: 10, weight: .regular)
    }
    
    static var Body2 : UIFont{
        return UIFont.systemFont(ofSize: 13, weight: .medium)
    }
    
    static var Button : UIFont{
        return UIFont.systemFont(ofSize: 15, weight: .bold)
    }
}

extension UIColor{
    
    static var buttonColor:  UIColor {
        return .black
    }
    
    static var buttonTextColor:  UIColor {
        return .white
    }
    
    static var optionContainerBackGroundColor:  UIColor {
        return UIColor(red: 241/255.0, green: 251/255.0, blue: 255/255.0, alpha: 0.55)
    }
    
    static func getTitleTextColor() -> UIColor {
        return UIColor(red: 37/255.0, green: 37/255.0, blue: 37/255.0, alpha: 1.0)
    }
    
    static func getSubTitleTextColor() -> UIColor {
        return UIColor(red: 140/255.0, green: 140/255.0, blue: 140/255.0, alpha: 1.0)
    }
    
    static func getGeneralBorderColor() -> UIColor{
        return UIColor.gray
    }
    
    static func getPlaceholderTextColor() -> UIColor{
        return UIColor.gray
    }
    
    static func grayBackGroundColor() -> UIColor{
        return UIColor(red: 237/255.0, green: 237/255.0, blue: 237/255.0, alpha: 1.0)
    }
    
    static var stepperIncrementIndicatorColor : UIColor{
        return UIColor(red: 251/255.0, green: 137/255.0, blue: 129/255.0, alpha: 1.0)
    }
    
    static var stepperDecrementIndicatorColor : UIColor{
        return UIColor(red: 171/255.0, green: 171/255.0, blue: 171/255.0, alpha: 1.0)
    }
    
    static var stepperMiddleColor : UIColor{
        return UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
    }
    
    static var viewBackgroundColor : UIColor {
        return UIColor(red: 245/255.0, green: 246/255.0, blue: 249/255.0, alpha: 1.0)
    }
    
    static var commentBarBackgroundColor : UIColor {
        return UIColor(red: 246/255.0, green: 247/255.0, blue: 248/255.0, alpha: 1.0)
    }
    
    static var feedCellBorderColor : UIColor {
        return .clear
    }
    
    static var unVotedPollOptionBorderColor : UIColor {
        return UIColor.getGeneralBorderColor()
    }
    
    static var votedPollOptionBorderColor : UIColor {
        return .black
    }
    
    static var progressColor : UIColor {
        return UIColor(red: 234/255.0, green: 239/255.0, blue: 242/255.0, alpha: 1.0)
    }
    
    static var progressTrackColor : UIColor {
        return .white
    }
    
}

struct AppliedCornerRadius {
    static let standardCornerRadius : CGFloat = 6.0
}

struct BorderWidths {
    static let standardBorderWidth : CGFloat = 1.0
    static let votedOptionBorderWidth : CGFloat = 1.5
}
