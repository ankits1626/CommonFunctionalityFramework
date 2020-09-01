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
        return 44
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? PollOptionsVotedTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            var delta = 1
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
            
           cell.optionContainerView?.borderedControl(
            borderColor: .unVotedPollOptionBorderColor,
            borderWidth: BorderWidths.standardBorderWidth
            )
            cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            cell.myOptionIndicator?.isHidden = !(feedOption?.hasVoted ?? false)

            cell.percentageVote?.text = "\(feedOption?.getPercentage() ?? 0) %"
            let progress = Float((feedOption?.getPercentage() ?? 0)) / 100.0
            print("progress is \(progress)")
            cell.percentageVoteIndicator?.setProgress(progress, animated: false )
            cell.percentageVoteIndicator?.progressTintColor = .lightGray
            cell.percentageVoteIndicator?.trackTintColor =  .progressTrackColor
        }
    }
    
}
