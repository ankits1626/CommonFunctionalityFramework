//
//  PollOptionsVotedTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PollOptionsVotedTableViewCellCoordinator:  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return PollOptionsVotedTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 52
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? PollOptionsVotedTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            var delta = 2
            if !(feed.getFeedTitle()?.isEmpty ?? true){
                delta = delta + 1
            }
            if !(feed.getFeedDescription()?.isEmpty ?? true){
                delta = delta + 1
            }
            let optionRowIndex = inputModel.targetIndexpath.row - delta
            let feedOption = feed.getPoll()?.getPollOptions()[optionRowIndex]
            cell.optionTitle?.text = feedOption?.title
            cell.optionTitle?.font = UIFont.Body1
            cell.containerView?.backgroundColor = UIColor.optionContainerBackGroundColor
            
//           cell.optionContainerView?.borderedControl(
//            borderColor: .unVotedPollOptionBorderColor,
//            borderWidth: BorderWidths.standardBorderWidth
//            )
            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
              //  cell.containerView?.addBorders(edges: [.left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
            }else{
               // cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            }
            cell.myOptionIndicator?.isHidden = true
            cell.optionContainerView?.layer.masksToBounds = true
            cell.optionContainerView?.layer.cornerRadius = 8.0
            cell.optionContainerView?.layer.borderWidth = 0.1
            cell.optionContainerView?.layer.borderColor = inputModel.themeManager?.getControlActiveColor().cgColor
            cell.circleLbl.backgroundColor = inputModel.themeManager?.getControlActiveColor()
            cell.percentageVote?.text = "\(feedOption?.getPercentage() ?? 0) %"
            let progress = Float((feedOption?.getPercentage() ?? 0)) / 100.0
            print("progress is \(progress)")
            cell.percentageVote?.textColor = inputModel.themeManager?.getControlActiveColor()
            cell.percentageVoteIndicator?.setProgress(progress, animated: false )
            cell.percentageVoteIndicator?.progressTintColor = feedOption?.optionColor
            cell.percentageVoteIndicator?.trackTintColor =  .progressTrackColor
        }
    }
    
}
