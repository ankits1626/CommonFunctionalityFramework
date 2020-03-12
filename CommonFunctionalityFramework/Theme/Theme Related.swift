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
}

struct AppliedCornerRadius {
    static let standardCornerRadius : CGFloat = 6.0
}
