//
//  FeedTopTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

struct FeedCellDequeueModel {
    var targetIndexpath : IndexPath
    var targetTableView : UITableView
    var cellIdentifier : String
}

struct FeedCellLoadDataModel {
    var targetIndexpath : IndexPath
    var targetCell : UITableViewCell
    var datasource: FeedsDatasource
}

struct FeedCellGetHeightModel {
    var targetIndexpath : IndexPath
    var datasource: FeedsDatasource
}

protocol FeedCellCongiguratorProtocol {
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell
}

class BaseFeedTableViewCellCoordinator {
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: inputModel.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
}

class FeedTopTableViewCellCoordinator:BaseFeedTableViewCellCoordinator,  FeedCellCoordinatorProtocol{
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 70
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedTopTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.userName?.text = feed.getUserName()
            cell.userName?.font = FontApplied.getAppliedFont(sizeType: .TitleTextSize, weight: .Regular)
            cell.userName?.textColor = UIColor.getTitleTextColor()
            cell.departmentName?.text = feed.getDepartmentName()
            cell.departmentName?.font = FontApplied.getAppliedFont(sizeType: .SubtitleTextSize, weight: .Regular)
            cell.departmentName?.textColor = UIColor.getSubTitleTextColor()
            cell.dateLabel?.text = feed.getfeedCreationDate()
            cell.dateLabel?.font = FontApplied.getAppliedFont(sizeType: .SubtitleTextSize, weight: .Regular)
            cell.dateLabel?.textColor = UIColor.getSubTitleTextColor()
            cell.containerView?.roundCorners(corners: [UIRectCorner.topRight, UIRectCorner.topLeft], radius: AppliedCoornerRadius.standardCornerRadius)
            cell.containerView?.addBorders(edges: [.top, .left, .right], color: UIColor.getGeneralBorderColor())
            //cell.containerView?.layer.borderWidth = 1.0
        }
    }
    
}
