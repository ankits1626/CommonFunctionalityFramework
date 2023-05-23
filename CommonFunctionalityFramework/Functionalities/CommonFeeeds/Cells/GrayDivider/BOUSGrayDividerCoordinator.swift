//
//  BOUSGrayDividerCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 14/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//


import UIKit
import Foundation

class BOUSGrayDividerCoordinator: CommonFeedCellCoordinatorProtocol{
    
    var cellType: CommonFeedCellTypeProtocol{
        return BOUSFeedGrayDividerCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 8
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? BOUSGrayDividerCoordinator{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            
        }
    }
    
}
