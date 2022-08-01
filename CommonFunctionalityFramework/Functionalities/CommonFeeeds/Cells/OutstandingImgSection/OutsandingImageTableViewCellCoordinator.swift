//
//  OutsandingImageTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 14/06/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Foundation


class OutsandingImageTableViewCellCoordinator: CommonFeedCellCoordinatorProtocol{
    
    var cellType: CommonFeedCellTypeProtocol{
        return CommonOutastandingImageTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 253
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonOutastandingImageTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            let feedNominationData = feed.getStrengthData()
            let bagesData = feed.getBadgesData()
            cell.strengthLabel?.text = feedNominationData["strengthName"] as! String
            cell.nominationMessage?.text =  feedNominationData["strengthMessage"] as! String
            
            if let badgeData = bagesData as? NSDictionary {
                if bagesData.count > 0 {
                    cell.awardLabel?.text = badgeData["badgeName"] as! String
                    cell.nominationImageView?.backgroundColor =  Rgbconverter.HexToColor(badgeData["badgeBackgroundColor"] as! String, alpha: 1)
                    cell.imageContainer?.backgroundColor = Rgbconverter.HexToColor(badgeData["badgeBackgroundColor"] as! String, alpha: 1)
                    cell.nominationConatiner?.backgroundColor = Rgbconverter.HexToColor(badgeData["badgeBackgroundColor"] as! String, alpha: 0.2)
                    inputModel.mediaFetcher.fetchImageAndLoad(cell.badgeImageView, imageEndPoint:  badgeData["badgeIcon"] as! String)
                }
  
            }
        }
    }
    
}




