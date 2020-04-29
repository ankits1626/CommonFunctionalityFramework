//
//  PollOptionsTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 13/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PollOptionsTableViewCellCoordinator:  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return PollOptionsTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 44
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? PollOptionsTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            var delta = 1
            if !(feed.getFeedTitle()?.isEmpty ?? true){
                delta = delta + 1
            }
            if !(feed.getFeedDescription()?.isEmpty ?? true){
                delta = delta + 1
            }
            let optionRowIndex = inputModel.targetIndexpath.row - delta
            let feedOption = feed.getPollOptions()?[optionRowIndex]
            cell.optionTitle?.text = feedOption?.title
            cell.optionTitle?.font = UIFont.Body1
            cell.containerView?.backgroundColor = UIColor.optionContainerBackGroundColor
            cell.optionContainerView?.layer.borderColor = UIColor.getGeneralBorderColor().cgColor
            cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
        }
    }
    
}
