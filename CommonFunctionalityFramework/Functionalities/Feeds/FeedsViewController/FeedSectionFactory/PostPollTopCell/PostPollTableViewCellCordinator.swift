//
//  PostPollTableViewCellCordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 14/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//
import UIKit

class PostPollTableViewCellCordinator: FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return PostPollTopTableViewCellTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 80
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? PostPollTopTableViewCellTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            if inputModel.targetIndexpath.section == 0 {
                cell.headerGrayViewHeight.constant = 0
            }else {
                cell.headerGrayViewHeight.constant = 10
            }
            
            let selectedtabValue = UserDefaults.standard.value(forKey: "selectedTab") as? String ?? ""
            cell.openUserProfileButton?.handleControlEvent(
                event: .touchUpInside,
                buttonActionBlock: {
                    inputModel.delegate?.showUserProfileView(
                        targetView: cell.editFeedButton,
                        feedIdentifier: feed.feedIdentifier
                    )
            })
            
            if selectedtabValue == "GreetingsFeed" {
                cell.userName?.text = feed.getUserName()
                cell.userName?.font = UIFont.Body2
                cell.userName?.textColor = UIColor.getTitleTextColor()
                cell.departmentName?.text = (feed.getDepartmentName() ?? "N/A") + " • " + (feed.getfeedCreationMonthDay() ?? "")
                cell.departmentName?.font = UIFont.Caption1
                cell.departmentName?.textColor = UIColor.getSubTitleTextColor()
                cell.dateLabel?.text = feed.getfeedCreationMonthDay()
                cell.dateLabel?.font = UIFont.Caption1
                cell.dateLabel?.textColor = UIColor.getSubTitleTextColor()
                cell.pinPostButton?.isHidden = true
                cell.pinImage?.isHidden =  true
                cell.containerView?.clipsToBounds = true
                cell.editFeedButton?.isHidden = true
                if let profileImageEndpoint = feed.getUserImageUrl(){
                    inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: profileImageEndpoint)
                }else{
                    cell.profileImage?.setImageForName(feed.getUserName() ?? "NN", circular: false, textAttributes: nil)
                }
                cell.profileImage?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
            }else {
                if feed.getFeedType() == .Greeting {
                    cell.userName?.text = feed.getOrganizationName()
                    cell.userName?.font = UIFont.Body2
                    cell.userName?.textColor = UIColor.getTitleTextColor()
                    cell.departmentName?.text = (feed.getfeedCreationMonthDay() ?? "")
                    cell.departmentName?.font = UIFont.Caption1
                    cell.departmentName?.textColor = UIColor.getSubTitleTextColor()
                    cell.dateLabel?.text = feed.getfeedCreationDate()
                    cell.dateLabel?.font = UIFont.Caption1
                    cell.dateLabel?.textColor = UIColor.getSubTitleTextColor()
                    cell.pinPostButton?.isHidden = feed.isPinToPost() ? false : true
                    cell.pinImage?.isHidden = feed.isPinToPost() ? false : true
                    cell.pinImage.setImageColor(color: UIColor.getControlColor())
                    cell.containerView?.clipsToBounds = true
                    cell.editFeedButton?.isHidden = true
                    
                    if let profileImageEndpoint = feed.getOrganizationLogo() {
                        inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageWithCompleteURL: profileImageEndpoint)
                    }else{
                        cell.profileImage?.setImageForName(feed.getUserName() ?? "NN", circular: false, textAttributes: nil)
                    }
                    cell.profileImage?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
                }else {
                    
                    cell.userName?.text = feed.getUserName()
                    cell.userName?.font = UIFont.Body2
                    cell.userName?.textColor = UIColor.getTitleTextColor()
                    cell.departmentName?.text = (feed.getDepartmentName() ?? "N/A") + " • " + (feed.getfeedCreationDate() ?? "")
                    cell.departmentName?.font = UIFont.Caption1
                    cell.departmentName?.textColor = UIColor.getSubTitleTextColor()
                    cell.dateLabel?.text = feed.getfeedCreationDate()
                    cell.dateLabel?.font = UIFont.Caption1
                    cell.dateLabel?.textColor = UIColor.getSubTitleTextColor()
                    cell.pinPostButton?.isHidden = feed.isPinToPost() ? false : true
                    cell.pinImage?.isHidden = feed.isPinToPost() ? false : true
                    cell.pinImage.setImageColor(color: UIColor.getControlColor())
                    cell.containerView?.clipsToBounds = true
//                     if !inputModel.datasource.shouldShowMenuOptionForFeed(){
//                        cell.editFeedButton?.isHidden = true
//                    }else{
//                        cell.editFeedButton?.isHidden = !feed.isActionsAllowed()
//                    }
                    cell.editFeedButton?.handleControlEvent(
                        event: .touchUpInside,
                        buttonActionBlock: {
                            inputModel.delegate?.showFeedEditOptions(
                                targetView: cell.editFeedButton,
                                feedIdentifier: feed.feedIdentifier
                            )
                    })
                    if let profileImageEndpoint = feed.getUserImageUrl(){
                        inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: profileImageEndpoint)
                    }else{
                        cell.profileImage?.setImageForName(feed.getUserName() ?? "NN", circular: false, textAttributes: nil)
                    }
                    cell.profileImage?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
                }
            }
        }
    }
    
}
