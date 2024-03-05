//
//  CommonFeedTopTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 03/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Foundation

class CommonFeedTopTableViewCellCoordinator: CommonFeedCellCoordinatorProtocol{
    
    let serverUrl = UserDefaults.standard.value(forKey: "base_url_for_image_height") as? String ?? ""
    
    var cellType: CommonFeedCellTypeProtocol{
        return CommonFeedsTopTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 80
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonFeedsTopTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            
            let selectedtabValue = UserDefaults.standard.value(forKey: "selectedTab") as? String ?? ""
            cell.profileImage?.setImageColor(color: UIColor.clear)
            cell.openUserProfileButton?.handleControlEvent(
                event: .touchUpInside,
                buttonActionBlock: {
                    inputModel.delegate?.showUserProfileView(
                        targetView: cell.editFeedButton,
                        feedIdentifier: feed.feedIdentifier
                    )
                })
            if selectedtabValue == "received" {
                cell.userName?.text =  "\("From".localized) \(feed.getUserName() ?? "")"
                cell.appraacitedBy.isHidden = true
                cell.dot.isHidden = true
                if let profileImageEndpoint = feed.getUserImageUrl(){
                    inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: profileImageEndpoint)
                }else{
                    cell.profileImage?.setImageForName(feed.getUserName() ?? "NN", circular: false, textAttributes: nil)
                }
            }else if selectedtabValue == "SearchFromHome" {
                if let nominatedName = feed.getHomeUserCreatedName() {
                    cell.appraacitedBy.text = "\("From".localized) \(nominatedName)"
                }
                if feed.getPostType() == .Appreciation {
                    cell.userName?.text = "\(feed.getHomeUserReceivedName() ?? "")"
                    if let profileImageEndpoint = feed.getHomeUserReceivedImg(){
                        inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: profileImageEndpoint)
                    }else{
                        cell.profileImage?.setImageForName(feed.getUserName() ?? "NN", circular: false, textAttributes: nil)
                    }
                }else {
                    let nominatedUser = feed.getNominatedUsers()
                    if nominatedUser.count > 0 && nominatedUser.count < 2 {
                        cell.userName?.text = "\(nominatedUser[0].fullName)"
                        if !nominatedUser[0].profilePic.isEmpty{
                            inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: nominatedUser[0].profilePic)
                        }else{
                            cell.profileImage?.setImageForName(nominatedUser[0].fullName , circular: false, textAttributes: nil)
                        }
                    }else {
                        cell.userName?.text = getCommaSeparatedUser(nominationUsers: nominatedUser)
                        cell.profileImage?.image = UIImage(named: "cff_ group_nomination_icon",
                                        in: Bundle(for: CommonFeedTopTableViewCellCoordinator.self),
                                        compatibleWith: nil)
                        cell.profileImage?.setImageColor(color: UIColor.getControlColor())
                    }
                }
            }else {
                if let toUserName = feed.toUserName() {
                    cell.userName?.text = "\("To".localized) \(toUserName)"
                    cell.appraacitedBy.isHidden = true
                    cell.dot.isHidden = true
                }
                
                if feed.getPostType() == .Appreciation {
                    if let toUserName = feed.toUserName() {
                        cell.userName?.text = "\("To".localized) \(toUserName)"
                    }
                    if let profileImageEndpoint = feed.getHomeUserReceivedImg(){
                        inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: profileImageEndpoint)
                    }else{
                        cell.profileImage?.setImageForName(feed.getUserName() ?? "NN", circular: false, textAttributes: nil)
                    }
                }else {
                    let nominatedUser = feed.getNominatedUsers()
                    if nominatedUser.count > 0 && nominatedUser.count < 2 {
                        cell.userName?.text = "\(nominatedUser[0].fullName)"
                        if !nominatedUser[0].profilePic.isEmpty{
                            inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: nominatedUser[0].profilePic)
                        }else{
                            cell.profileImage?.setImageForName(nominatedUser[0].fullName , circular: false, textAttributes: nil)
                        }
                    }else {
                        cell.userName?.text = getCommaSeparatedUser(nominationUsers: nominatedUser)
                        cell.profileImage?.image = UIImage(named: "cff_ group_nomination_icon",
                                                           in: Bundle(for: CommonFeedTopTableViewCellCoordinator.self),
                                                           compatibleWith: nil)
                        cell.profileImage?.setImageColor(color: UIColor.getControlColor())
                    }
                }
                
                
            }
            
            cell.dateLabel?.text = feed.getAppreciationCreationMonthDate()
//            if !inputModel.datasource.shouldShowMenuOptionForFeed(){
//                cell.editFeedButton?.isHidden = (feed.getNewFeedType() == .Poll || feed.getNewFeedType() == .Post) ? true : !feed.isFeedReportAbuseAllowed()
//            }else{
//                cell.editFeedButton?.isHidden = (feed.getNewFeedType() == .Poll || feed.getNewFeedType() == .Post) ?  !feed.isActionsAllowed() : !feed.isFeedReportAbuseAllowed()
//            }
//            cell.editFeedButton?.isHidden = !feed.isActionsAllowed()
            cell.editFeedButton?.handleControlEvent(
                event: .touchUpInside,
                buttonActionBlock: {
                    inputModel.delegate?.showFeedEditOptions(
                        targetView: cell.editFeedButton,
                        feedIdentifier: feed.feedIdentifier
                    )
                })
        }
    }
    
    func getCommaSeparatedUser(nominationUsers : [NominationNominatedMembers]) -> String {
        let userName = nominationUsers[0].fullName
        let userName2 = nominationUsers[1].fullName
        let remainingCount = nominationUsers.count > 1 ? " + \(nominationUsers.count - 1)..."  : ""
        return userName + ", " + userName2 + remainingCount
    }
    
}


