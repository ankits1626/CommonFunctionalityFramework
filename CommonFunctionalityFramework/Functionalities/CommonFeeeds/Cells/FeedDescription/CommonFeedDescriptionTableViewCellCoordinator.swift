//
//  CommonFeedDescriptionTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 05/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Foundation

class CommonFeedDescriptionTableViewCellCoordinator: CommonFeedCellCoordinatorProtocol{
    
    var cellType: CommonFeedCellTypeProtocol{
        return CommonFeedDescriptionTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonFeedDescriptionTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            //cell.feedText?.enabledTypes  = [.mention, .hashtag, .url, .email]
            cell.feedText?.attributedText = NSAttributedString(string: "Thank you for yoursupport@rewardz.sg #rewardz #suyesh")
            cell.feedText?.numberOfLines = 3
//            cell.feedText?.enabledTypes  = [.mention, .hashtag, .url, .email]
//            cell.feedText?.attributedText = NSAttributedString(string: "Thank you for yoursupport@rewardz.sg #rewardz #suyesh")
//            cell.feedText?.numberOfLines = 3
//            cell.userName?.text = feed.getUserName()
//            cell.userName?.font = UIFont.Body2
//            cell.userName?.textColor = UIColor.getTitleTextColor()
//            cell.departmentName?.text = feed.getDepartmentName()
//            cell.departmentName?.font = UIFont.Caption1
//            cell.departmentName?.textColor = UIColor.getSubTitleTextColor()
//            cell.dateLabel?.text = feed.getfeedCreationDate()
//            cell.dateLabel?.font = UIFont.Caption1
//            cell.dateLabel?.textColor = UIColor.getSubTitleTextColor()
//            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
//                cell.containerView?.roundCorners(corners: [.topLeft, .topRight], radius: 0)
//                cell.containerView?.addBorders(edges: [.top, .left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
//            }else{
//                cell.containerView?.roundCorners(corners: [.topLeft, .topRight], radius: AppliedCornerRadius.standardCornerRadius)
//                cell.containerView?.addBorders(edges: [.top, .left, .right], color: .feedCellBorderColor)
//            }
//            cell.pinPostButton?.setImage(
//                UIImage(
//                    named: feed.isPinToPost() ? "cff_coloredPinPostIcon" : "cff_pinPostIcon",
//                    in: Bundle(for: CommonFeedTopTableViewCell.self),
//                    compatibleWith: nil),
//                for: .normal
//            )
//            cell.pinPostButton?.isHidden = !feed.isLoggedUserAdmin()
//            cell.containerView?.clipsToBounds = true
//             if !inputModel.datasource.shouldShowMenuOptionForFeed(){
//                cell.editFeedButton?.isHidden = true
//            }else{
//                cell.editFeedButton?.isHidden = !feed.isActionsAllowed()
//            }
//            cell.pinPostButton?.handleControlEvent(
//                event: .touchUpInside, buttonActionBlock: {
//                    inputModel.delegate?.pinToPost(
//                        feedIdentifier: feed.feedIdentifier,
//                        isAlreadyPinned: feed.isPinToPost()
//                    )
//                }
//            )
//            cell.editFeedButton?.handleControlEvent(
//                event: .touchUpInside,
//                buttonActionBlock: {
//                    inputModel.delegate?.showFeedEditOptions(
//                        targetView: cell.editFeedButton,
//                        feedIdentifier: feed.feedIdentifier
//                    )
//            })
//            if let profileImageEndpoint = feed.getUserImageUrl(){
//                inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: profileImageEndpoint)
//            }else{
//                cell.profileImage?.image = nil
//            }
        }
    }
    
}




