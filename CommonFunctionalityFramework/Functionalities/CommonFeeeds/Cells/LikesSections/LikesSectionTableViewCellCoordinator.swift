//
//  LikesSectionTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 04/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Foundation

class LikesSectionTableViewCellCoordinator: CommonFeedCellCoordinatorProtocol{
    
    var cellType: CommonFeedCellTypeProtocol{
        return CommonLikesSectionTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 50
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonLikesSectionTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
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




