//
//  BOUSReactionScrollListCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 22/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import UIKit

class BOUSReactionScrollListCellCoordinator :  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return BOUSReactionScrollListTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 100
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? BOUSDetailFeedOutstandingTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            
            
           
        }
    }
    
}
