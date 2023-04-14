//
//  AnniversaryTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 08/02/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import UIKit

class AnniversaryTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return AnniversaryDetailTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 270
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? BOUSDetailFeedOutstandingTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            let feedNominationData = feed.getStrengthData()
            let bagesData = feed.getBadgesData()
        }
    }
    
}
