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
            cell.departmentName?.text = feed.getDepartmentName()
            cell.dateLabel?.text = feed.getfeedCreationDate()
            cell.containerView?.roundCorners(corners: [UIRectCorner.topRight, UIRectCorner.topLeft], radius: 8)
            cell.containerView?.addBorders(edges: [.top, .left, .right], color: .black)
            //cell.containerView?.layer.borderWidth = 1.0
        }
    }
    
}
