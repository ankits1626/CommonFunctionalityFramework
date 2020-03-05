//
//  FeedTextTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedTextTableViewCellCoordinator : BaseFeedTableViewCellCoordinator,  FeedCellCoordinatorProtocol{
    
    override func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        let targetCell = super.getCell(inputModel)
        if let cell  = targetCell as? FeedTextTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.feedText?.text = feed.getFeedDescription()
            cell.feedText?.font = FontApplied.getAppliedFont(sizeType: .MediumTextSize, weight: .Regular)
            cell.feedText?.textColor = UIColor.getTitleTextColor()
            cell.containerView?.addBorders(edges: [.left, .right], color: UIColor.getGeneralBorderColor())
            cell.readMorebutton?.isHidden = !(cell.feedText?.isTruncated ?? false)
        }
        return targetCell
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
    }
    
}
