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
            cell.awardSubTitle?.text = feedNominationData["strengthName"] as! String
            cell.awardDescription?.text =  feedNominationData["strengthMessage"] as! String
            cell.awardTitle.text = bagesData["badgeName"] as! String
            //cell.backView.backgroundColor = Rgbconverter.HexToColor(appCoordinator.getOrgBackgroundColor(), alpha: 1.0)
            inputModel.mediaFetcher.fetchImageAndLoad(cell.awardImg, imageEndPoint:  bagesData["badgeIcon"] as! String)
           
        }
    }
    
}




