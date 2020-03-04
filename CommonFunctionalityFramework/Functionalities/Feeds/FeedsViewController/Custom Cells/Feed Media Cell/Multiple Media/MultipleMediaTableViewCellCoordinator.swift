//
//  MultipleMediaTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class MultipleMediaTableViewCellCoordinator : BaseFeedTableViewCellCoordinator,  FeedCellCoordinatorProtocol{
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
         let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
        switch feed.getMediaCountState() {
        
        case .None:
            return 0
        case .OneMediaItemPresent(let mediaType):
            return 0
        case .TwoMediaItemPresent:
            return 90
        case .MoreThanTwoMediItemPresent:
            return 57
        }
    }
    
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? MultipleMediaTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.containerView?.addBorders(edges: [.left, .right], color: .black)
        }
    }
    
}


