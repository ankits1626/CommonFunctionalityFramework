//
//  FontApplied.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

enum FontSizeType : Int {
    case TitleTextSize = 13
    case SubtitleTextSize = 10
    case MediumTextSize = 11
    case BoldTitleSize = 18
    case SmallTextSize = 9
}

enum FontWeight : String {
    case Regular = "Regular"
    case Thin = "Thin"
    case Medium = "Medium"
    case Bold = "Bold"
}

class FontApplied {
    static func getAppliedFont(sizeType : FontSizeType, weight : FontWeight) -> UIFont?{
        let fontName = "Montserrat-\(weight.rawValue)"
        return UIFont(name: fontName, size: CGFloat(sizeType.rawValue))
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
}

struct AppliedCoornerRadius {
    static let standardCornerRadius : CGFloat = 6.0
}
