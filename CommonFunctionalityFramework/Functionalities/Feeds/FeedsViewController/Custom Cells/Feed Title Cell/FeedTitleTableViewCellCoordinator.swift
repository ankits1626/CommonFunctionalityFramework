//
//  FeedTitleTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedTitleTableViewCellCoordinator:  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return FeedTitleTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 24
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedTitleTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.feedTitle?.text = feed.getFeedTitle()
            cell.feedTitle?.font = UIFont.Title1
            cell.feedTitle?.textColor = UIColor.getTitleTextColor()
            cell.containerView?.addBorders(edges: [.left, .right], color: UIColor.getGeneralBorderColor())
        }
    }
    
}
