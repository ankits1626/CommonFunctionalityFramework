//
//  ClappedByTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 11/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class ClappedByTableViewCellCoordinator:  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return ClappedByTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 91
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? ClappedByTableViewCell{
            cell.containerView?.addBorders(edges: [.left, .right], color: UIColor.getGeneralBorderColor())
            cell.seeAllButton?.handleControlEvent(
                event: .touchUpInside,
                buttonActionBlock: {
                    inputModel.delegate.showLikedByUsersList()
            })
        }
    }
    
}
