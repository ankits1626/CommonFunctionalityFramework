//
//  LikesSectionTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 04/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Foundation

class LikesSectionTableViewCellCoordinator: CommonFeedCellCoordinatorProtocol{
    
    var cellType: CommonFeedCellTypeProtocol{
        return CommonLikesSectionTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 50
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonLikesSectionTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.reactionCountBtn.handleControlEvent(event: .touchUpInside,   buttonActionBlock: {
                inputModel.delegate?.showPostReactions(
                    feedIdentifier: feed.feedIdentifier
                )
            })
        }
    }
    
}




