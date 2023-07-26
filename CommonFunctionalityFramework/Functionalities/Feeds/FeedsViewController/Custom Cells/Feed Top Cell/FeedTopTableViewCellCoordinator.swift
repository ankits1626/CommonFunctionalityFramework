//
//  FeedTopTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

struct FeedCellDequeueModel {
    var targetIndexpath : IndexPath
    var targetTableView : UITableView
    var datasource: FeedsDatasource
    var isFeedDetailPage : Bool
    weak var themeManager: CFFThemeManagerProtocol?
    weak var mainAppCoordinator : CFFMainAppInformationCoordinator?
}

struct FeedCellLoadDataModel {
    var targetIndexpath : IndexPath
    var targetTableView: UITableView?
    var targetCell : UITableViewCell
    weak var datasource: FeedsDatasource!
    var mediaFetcher: CFFMediaCoordinatorProtocol
    weak var delegate : FeedsDelegate?
    weak var selectedoptionMapper : SelectedPollAnswerMapper?
    weak var themeManager: CFFThemeManagerProtocol?
    weak var mainAppCoordinator : CFFMainAppInformationCoordinator?
    var isFeedDetailPage : Bool
    var selectedTab : String
    var canDownload : Bool = false
    var isDesklessEnabled : Bool = false
}

struct FeedCellGetHeightModel {
    var targetIndexpath : IndexPath
    weak var datasource: FeedsDatasource!
}

protocol FeedCellCongiguratorProtocol {
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell
}

class FeedTopTableViewCellCoordinator: FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return FeedTopTableViewCellType()
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
        if let cell  = inputModel.targetCell as? FeedTopTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
//            cell.userName?.text = feed.getUserName()
//            if let nominatedName = feed.getNominatedByUserName() {
//                cell.appraacitedBy.text = "From \(nominatedName)"
//            }

            let selectedtabValue = UserDefaults.standard.value(forKey: "selectedTab") as? String ?? ""
            if selectedtabValue == "received" {
                cell.userName?.text =  "From \(feed.getUserName() ?? "")"
                cell.appraacitedBy.isHidden = true
                cell.dot.isHidden = true
                if let profileImageEndpoint = feed.getUserImageUrl(){
                    inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: profileImageEndpoint)
                }else{
                    cell.profileImage?.setImageForName(feed.getUserName() ?? "NN", circular: false, textAttributes: nil)
                }
            }else if selectedtabValue == "SearchFromHome" {
                if let nominatedName = feed.getHomeUserCreatedName() {
                    cell.appraacitedBy.text = "From \(nominatedName)"
                }
                cell.userName?.text = "\(feed.getHomeUserReceivedName() ?? "")"
                if let profileImageEndpoint = feed.getHomeUserReceivedImg(){
                    inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: profileImageEndpoint)
                }else{
                    if let nominatedName = feed.getNominatedByUserName() {
                        cell.profileImage?.setImageForName(nominatedName ?? "NN", circular: false, textAttributes: nil)
                    }
                }
            }else {
                if let toUserName = feed.toUserName() {
                    cell.userName?.text = "To \(toUserName)"
                    cell.appraacitedBy.isHidden = true
                    cell.dot.isHidden = true
                }
                if let profileImageEndpoint = feed.getGivenTabUserImg(){
                    inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: profileImageEndpoint)
                }else{
                    cell.profileImage?.setImageForName(feed.getUserName() ?? "NN", circular: false, textAttributes: nil)
                }
            }

            cell.userName?.font = UIFont.Body2
            cell.userName?.textColor = UIColor.getTitleTextColor()
            cell.departmentName?.text = feed.getDepartmentName()
            cell.departmentName?.font = UIFont.Caption1
            cell.departmentName?.textColor = UIColor.getSubTitleTextColor()
            cell.dateLabel?.text = feed.getAppreciationCreationMonthDate()
            //cell.dateLabel?.font = UIFont.Caption1
            //cell.dateLabel?.textColor = UIColor.getSubTitleTextColor()
            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
                cell.containerView?.roundCorners(corners: [.topLeft, .topRight], radius: 0)
                cell.containerView?.addBorders(edges: [.top, .left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
            }else{
                cell.containerView?.roundCorners(corners: [.topLeft, .topRight], radius: AppliedCornerRadius.standardCornerRadius)
                cell.containerView?.addBorders(edges: [.top, .left, .right], color: .feedCellBorderColor)
            }
            cell.pinPostButton?.setImage(
                UIImage(
                    named: feed.isPinToPost() ? "cff_coloredPinPostIcon" : "cff_pinPostIcon",
                    in: Bundle(for: FeedTopTableViewCell.self),
                    compatibleWith: nil),
                for: .normal
            )
            cell.pinPostButton?.isHidden = true
            cell.containerView?.clipsToBounds = true
             if !inputModel.datasource!.shouldShowMenuOptionForFeed(){
                cell.editFeedButton?.isHidden = (feed.getNewFeedType() == .Poll || feed.getNewFeedType() == .Post) ? true : !feed.isFeedReportAbuseAllowed()
            }else{
                cell.editFeedButton?.layer.borderWidth = 1
                cell.editFeedButton?.layer.masksToBounds = true
                cell.editFeedButton?.layer.cornerRadius = 8
                cell.editFeedButton?.layer.borderColor = #colorLiteral(red: 0.9294112921, green: 0.9411767125, blue: 0.9999989867, alpha: 1)
                cell.editFeedButton?.isHidden = (feed.getNewFeedType() == .Poll || feed.getNewFeedType() == .Post) ?  !feed.isActionsAllowed() : !feed.isFeedReportAbuseAllowed()
            }
            if let unwrappedDelegate = inputModel.delegate{
                cell.pinPostButton?.handleControlEvent(
                    event: .touchUpInside, buttonActionBlock: {
                        unwrappedDelegate.pinToPost(
                            feedIdentifier: feed.feedIdentifier,
                            isAlreadyPinned: feed.isPinToPost()
                        )
                    }
                )
                cell.editFeedButton?.handleControlEvent(
                    event: .touchUpInside,
                    buttonActionBlock: {
                        unwrappedDelegate.showFeedEditOptions(
                            targetView: cell.editFeedButton,
                            feedIdentifier: feed.feedIdentifier
                        )
                })
            }
            
            cell.pinPostButton?.handleControlEvent(
                event: .touchUpInside, buttonActionBlock: {
                    inputModel.delegate?.pinToPost(
                        feedIdentifier: feed.feedIdentifier,
                        isAlreadyPinned: feed.isPinToPost()
                    )
                }
            )
            
            if inputModel.isDesklessEnabled {
                if  feed.getPostType() == .Appreciation {
                    if inputModel.canDownload {
                        cell.editFeedButton?.layer.borderWidth = 0
                        cell.editFeedButton?.setImage(UIImage(named: "icon_setasdefault-2"), for: .normal)
                        cell.editFeedButton?.isHidden = false
                        cell.editFeedButton?.handleControlEvent(
                            event: .touchUpInside,
                            buttonActionBlock: {
                                inputModel.delegate?.showFeedEditOptions(
                                    targetView: cell.editFeedButton,
                                    feedIdentifier: feed.feedIdentifier
                                )
                            })
                    }else {
                        cell.editFeedButton?.isHidden = true
                    }
                }
            }else {
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
    }
}
