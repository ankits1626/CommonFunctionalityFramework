//
//  FeedTextTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedTextTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return FeedTextTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        let targetCell = inputModel.targetTableView.dequeueReusableCell(
        withIdentifier: cellType.cellIdentifier,
        for: inputModel.targetIndexpath)
        if let cell  = targetCell as? FeedTextTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            if inputModel.datasource.showShowFullfeedDescription(){
                cell.feedText?.numberOfLines = 0
            }
            cell.feedText?.text = feed.getFeedDescription()
            cell.feedText?.font = UIFont.Body1
            cell.feedText?.textColor = UIColor.getTitleTextColor()
            cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            if inputModel.datasource.showShowFullfeedDescription(){
                cell.readMorebutton?.isHidden = true
            }else{
               cell.readMorebutton?.isHidden = !(cell.feedText?.isTruncated ?? false)
            }
            cell.readMorebutton?.isUserInteractionEnabled = false
        }
        return targetCell
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
    }
    
}
