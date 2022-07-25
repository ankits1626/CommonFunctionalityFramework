//
//  CommonAppreciationSubjectTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 04/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Foundation

class CommonAppreciationSubjectTableViewCellCoordinator: CommonFeedCellCoordinatorProtocol{
    
    var cellType: CommonFeedCellTypeProtocol{
        return CommonAppreciationSubjectTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonAppreciationSubjectTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.feedText?.numberOfLines = 3
            let feedTitle = feed.getStrengthData()
            cell.feedText?.text = feedTitle["strengthMessage"] as! String
            cell.appreciationSubject?.text =  feedTitle["strengthName"] as! String
            inputModel.mediaFetcher.fetchImageAndLoad(cell.feedThumbnail, imageEndPoint: feedTitle["strengthIcon"] as! String)
            cell.containerView?.backgroundColor = Rgbconverter.HexToColor(feedTitle["badgeBackgroundColor"] as! String, alpha: 1.0)
            
            if let mediaItem = feed.getMediaList()?.first,
                let _ = mediaItem.getCoverImageUrl(){
                cell.containerView?.roundCorners(corners: [.topLeft, .topRight], radius: 0)
            }else if let gifItem = feed.getGiphy() {
                if !gifItem.isEmpty {
                    cell.containerView?.roundCorners(corners: [.topLeft, .topRight], radius: 0)
                }
            }else {
                cell.containerView?.layer.masksToBounds = true
                cell.containerView?.layer.cornerRadius = 8
            }
            
            
            
        }
    }
    
}



