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
            cell.strengthLabel?.text = feedNominationData["strengthName"] as! String
            cell.nominationMessage?.text =  feedNominationData["strengthMessage"] as! String
            cell.awardLabel?.text = bagesData["badgeName"] as! String
            cell.nominationImageView?.backgroundColor =  Rgbconverter.HexToColor(bagesData["badgeBackgroundColor"] as! String, alpha: 1)
            cell.imageContainer?.backgroundColor = Rgbconverter.HexToColor(bagesData["badgeBackgroundColor"] as! String, alpha: 1)
            cell.nominationConatiner?.backgroundColor = Rgbconverter.HexToColor(bagesData["badgeBackgroundColor"] as! String, alpha: 0.2)
            inputModel.mediaFetcher.fetchImageAndLoad(cell.badgeImageView, imageEndPoint:  bagesData["badgeIcon"] as! String)
        }
    }
    
}
