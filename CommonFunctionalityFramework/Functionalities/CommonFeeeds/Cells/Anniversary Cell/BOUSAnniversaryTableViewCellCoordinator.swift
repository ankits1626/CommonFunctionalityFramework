//
//  BOUSAnniversaryTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 03/02/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//
import UIKit
import Foundation


class BOUSAnniversaryBirthdayImageTableViewCellCoordinator: FeedCellCoordinatorProtocol{
    
    var cellType: FeedCellTypeProtocol{
        return BOUSAnniversaryTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 343
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? BOUSAnniversaryTableViewCell {
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            let feedData = feed.getGreeting()
            inputModel.mediaFetcher.fetchImageAndLoad(cell.userImg, imageEndPoint: URL(string: feedData?.thumbnail ?? ""))
            if feedData?.type == "Anniversary" {
                cell.wishType?.image = UIImage(named: "anni_small_icon")
                cell.bgTransparentImg.image = UIImage(named: "bg-anni")
                cell.imageHolder.backgroundColor = UIColor(red: 88, green: 86, blue: 214)
//                cell.wishTitle.text = "It's \(feedData?.user_first_name ?? "" ) \(feedData?.user_last_name ?? "") Anniversary"
            }else {
                cell.wishType?.image = UIImage(named: "bday_small_icon")
                cell.bgTransparentImg.image = UIImage(named: "bg_bday")
                cell.imageHolder.backgroundColor = UIColor(red: 54, green: 164, blue: 214)
//                cell.wishTitle.text = "It's \(feedData?.user_first_name ?? "" ) \(feedData?.user_last_name ?? "") Birthday"
            }
            cell.wishTitle.text = getGrretingTitleString(userGreetingDataObject: feedData!, userPk: inputModel.mainAppCoordinator?.getUserPK() ?? 0)
            
            if let profileImageEndpoint = feed.getUserImageUrl() {
                inputModel.mediaFetcher.fetchImageAndLoad(cell.userImg, imageEndPoint: profileImageEndpoint)
            }else{
                cell.userImg?.setImageForName(feed.getUserName() ?? "NN", circular: false, textAttributes: nil)
            }
            cell.userImg?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
            
            cell.imageHolder.layer.borderWidth = 2.0
            cell.imageHolder.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            cell.userNameTitle.text = "\(feedData?.user_first_name ?? "" ) \(feedData?.user_last_name ?? "")"
            cell.departmentTitle.text = feedData?.department_name ?? ""
        }
    }
    
    
    func getGrretingTitleString(userGreetingDataObject: GreetingAnniAndBday, userPk: Int) -> String {
        let formattedDate = getdateFromStringFrom(userGreetingDataObject.date ?? "", dateFormat: "yyyy-MM-dd")
        let typeOfGreetings = userGreetingDataObject.type ?? ""
        
        if Date().getDatePart() == formattedDate.getDatePart() {
            if !userGreetingDataObject.user_email.isEmpty {
                if userGreetingDataObject.userPk == userPk {
                    return "\(NSLocalizedString("It's your", comment: "")) \("\(userGreetingDataObject.type == "Anniversary" ? " \(userGreetingDataObject.yearCompleted?.dob ?? "") " : "")") \(typeOfGreetings)\("VN PostFix It's your".localized) \(NSLocalizedString("Today", comment: ""))"
                    //btnSendWishes = true
                } else {
                    return "\(NSLocalizedString("It's \(userGreetingDataObject.user_first_name) \(userGreetingDataObject.user_last_name)'s", comment: "")) \("\(userGreetingDataObject.type == "Anniversary" ? "\(userGreetingDataObject.yearCompleted?.dob ?? "") " : "")") \(typeOfGreetings)\("VN PostFix It's your Colleague's".localized) \(NSLocalizedString("Today", comment: ""))"
                }
            }
        } else {
            if Date() > formattedDate {
                if !userGreetingDataObject.user_email.isEmpty {
                    if userGreetingDataObject.userPk == userPk {
                        return "\(NSLocalizedString("It was your", comment: "")) \("\(userGreetingDataObject.type == "Anniversary" ? " \(userGreetingDataObject.yearCompleted?.dob ?? "") " : "")") \(typeOfGreetings)\("VN PostFix It was your".localized)"
                        //btnSendWishes = true
                    } else {
                        return "\(NSLocalizedString("It was \(userGreetingDataObject.user_first_name) \(userGreetingDataObject.user_last_name)'s", comment: "")) \("\(userGreetingDataObject.type == "Anniversary" ? " \(userGreetingDataObject.yearCompleted?.dob ?? "") " : "")")\(typeOfGreetings)\("VN PostFix It was your Colleague's".localized)"
                    }
                }
            } else {
                if !userGreetingDataObject.user_email.isEmpty {
                    if userGreetingDataObject.userPk == userPk {
                        return "\(NSLocalizedString("It's your", comment: ""))\("\(userGreetingDataObject.type == "Anniversary" ? " \(userGreetingDataObject.yearCompleted?.dob ?? "") " : "")") \(typeOfGreetings)\("VN PostFix It's your".localized)"
                            //btnSendWishes = true
                    } else {
                        return "\(NSLocalizedString("It's your \(userGreetingDataObject.user_first_name) \(userGreetingDataObject.user_last_name)'s", comment: "")) \("\(userGreetingDataObject.type == "Anniversary" ? " \(userGreetingDataObject.yearCompleted?.dob ?? "") " : "")") \(typeOfGreetings)\("VN PostFix It's your Colleague's".localized)"
                    }
                }
            }
        }
        return ""
    }
    
    func getdateFromStringFrom(_ date : String, dateFormat: String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US")
        if let strDate = dateFormatter.date(from: date)
        {
            return strDate
        }
        return Date()
    }
}

extension Int {
    var dob: String {
        var suffix: String
        let ones: Int = self % 10
        let tens: Int = (self/10) % 10
        if tens == 1 {
            suffix = NSLocalizedString("th", comment: "")
        } else if ones == 1 {
            suffix = NSLocalizedString("st", comment: "")
        } else if ones == 2 {
            suffix = NSLocalizedString("nd", comment: "")
        } else if ones == 3 {
            suffix = NSLocalizedString("rd", comment: "")
        } else {
            suffix = NSLocalizedString("th", comment: "")
        }
        return "\(self)\(suffix)"
    }

}
