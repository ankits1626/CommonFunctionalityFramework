//
//  PollBottomTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PollBottomTableViewCellCoordinator:  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return PollBottomTableViewCelType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 44
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? PollBottomTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.containerView?.backgroundColor = UIColor.optionContainerBackGroundColor
            cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            cell.containerView?.roundCorners(corners: [.bottomLeft, .bottomRight], radius: AppliedCornerRadius.standardCornerRadius)
            cell.messageLabel?.textColor = .black
            cell.messageLabel?.font = .Highlighter1
            cell.messageLabel?.text = feed.getPoll()?.getPollInfo()
        }
    }
    
}
