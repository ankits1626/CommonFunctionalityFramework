//
//  FeedTextTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedTextTableViewCellCoordinator : BaseFeedTableViewCellCoordinator,  FeedCellCoordinatorProtocol{
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 200
    }
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedTextTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.feedText?.text = feed.getFeedDescription()
            cell.feedText?.font = FontApplied.getAppliedFont(sizeType: .MediumTextSize, weight: .Regular)
            cell.feedText?.textColor = UIColor.getTitleTextColor()
            cell.containerView?.addBorders(edges: [.left, .right], color: UIColor.getGeneralBorderColor())
        }
    }
    
}
