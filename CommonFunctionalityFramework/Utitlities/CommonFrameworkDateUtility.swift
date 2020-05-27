//
//  CommonFrameworkUtility.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation
class CommonFrameworkDateUtility {
    static func getDateFromStringFrom(_ date : String, dateFormat: String) -> Date?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let strDate = dateFormatter.date(from: date)
        {
            return strDate
        }
        return nil
    }
    
    static func getDisplayedDateInFormatDMMMYYYY(input: String, dateFormat : String) -> String?{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from:input)!
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        dateFormatter.dateFormat = "d MMM yyyy"
        return dateFormatter.string(from: calendar.date(from:components)!)
    }
    
    static func getDisplayableDate(input: String, dateFormat : String) -> String?{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from:input)!
        let days =  getDaysDifferenceBetweenTwoDates(from: Date(), to: date)
        
        if days == 0{
            return "Today"
        }
        else if days == -1{
            return "Yesterday"
        }else{
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            dateFormatter.dateFormat = "dd-MM-yyyy"
            return dateFormatter.string(from: calendar.date(from:components)!)
        }
    }
    
    static  func getDaysDifferenceBetweenTwoDates(from: Date, to : Date) -> Int{
        return Calendar.current.dateComponents([.day], from: from, to: to).day ?? 0
    }
}
