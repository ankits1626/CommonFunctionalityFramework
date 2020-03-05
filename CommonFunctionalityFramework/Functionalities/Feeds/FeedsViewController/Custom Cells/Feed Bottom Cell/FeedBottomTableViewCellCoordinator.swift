//
//  FeedBottomTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedBottomTableViewCellCoordinator : BaseFeedTableViewCellCoordinator,  FeedCellCoordinatorProtocol{
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 59
    }
    
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedBottomTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.commentsCountLabel?.text = feed.getNumberOfComments()
            cell.commentsCountLabel?.font = FontApplied.getAppliedFont(sizeType: .SmallTextSize, weight: .Regular)
            cell.commentsCountLabel?.textColor = UIColor.getSubTitleTextColor()
            
            cell.clapsCountLabel?.text = feed.getNumberOfClaps()
            cell.clapsCountLabel?.font = FontApplied.getAppliedFont(sizeType: .SmallTextSize, weight: .Regular)
            cell.clapsCountLabel?.textColor = UIColor.getSubTitleTextColor()
            
            cell.containerView?.roundCorners(corners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight], radius: AppliedCoornerRadius.standardCornerRadius)
            cell.containerView?.addBorders(edges: [.bottom, .left, .right], color: UIColor.getGeneralBorderColor())
        }
    }
    
}
