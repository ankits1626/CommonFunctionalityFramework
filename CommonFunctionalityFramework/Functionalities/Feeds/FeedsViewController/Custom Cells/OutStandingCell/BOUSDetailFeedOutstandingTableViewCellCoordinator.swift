//
//  BOUSDetailFeedOutstandingTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSDetailFeedOutstandingTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return FeedDetailOutstandingTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 253
    }
    
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? BOUSDetailFeedOutstandingTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            
            let feedNominationData = feed.getStrengthData()
            let bagesData = feed.getBadgesData()
            cell.awardSubTitle?.text = feedNominationData["strengthName"] as! String
            cell.awardDescription?.text =  feedNominationData["strengthMessage"] as! String
            cell.awardTitle.text = bagesData["badgeName"] as! String
            //cell.backView.backgroundColor = Rgbconverter.HexToColor(appCoordinator.getOrgBackgroundColor(), alpha: 1.0)
            inputModel.mediaFetcher.fetchImageAndLoad(cell.awardImg, imageEndPoint:  bagesData["badgeIcon"] as! String)
           
        }
    }
    
}
