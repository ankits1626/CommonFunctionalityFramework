//
//  SingleVideoTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class SingleVideoTableViewCellCoordinator : BaseFeedTableViewCellCoordinator,  FeedCellCoordinatorProtocol{
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 205
    }
    
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? SingleVideoTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.containerView?.addBorders(edges: [.left, .right], color: UIColor.getGeneralBorderColor())
        }
    }
    
}

