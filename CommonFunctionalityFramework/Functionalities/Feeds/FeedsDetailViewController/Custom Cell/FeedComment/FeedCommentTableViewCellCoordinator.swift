//
//  FeedCommentTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 11/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedCommentTableViewCellCoordinator:  FeedCellCoordinatorProtocol{
    
    var cellType: FeedCellTypeProtocol{
        return FeedCommentTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {

    }
    
}
