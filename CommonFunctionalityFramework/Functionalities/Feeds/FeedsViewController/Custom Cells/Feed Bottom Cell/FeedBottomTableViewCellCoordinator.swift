//
//  FeedBottomTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedBottomTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return FeedBottomTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 59
    }
    
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedBottomTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.commentsCountLabel?.text = feed.getNumberOfComments()
            cell.commentsCountLabel?.font = UIFont.Caption1
            cell.commentsCountLabel?.textColor = UIColor.getSubTitleTextColor()
            cell.clapsCountLabel?.text = feed.getNumberOfClaps()
            cell.clapsCountLabel?.font = UIFont.Caption1
            cell.clapsCountLabel?.textColor = UIColor.getSubTitleTextColor()
            cell.containerView?.addBorders(edges: [.bottom, .left, .right], color: UIColor.getGeneralBorderColor())
        }
    }
    
}
