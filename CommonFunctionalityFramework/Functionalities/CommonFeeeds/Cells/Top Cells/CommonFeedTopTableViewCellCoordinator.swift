//
//  CommonFeedTopTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 03/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Foundation

class CommonFeedTopTableViewCellCoordinator: CommonFeedCellCoordinatorProtocol{
    
    var cellType: CommonFeedCellTypeProtocol{
        return CommonFeedsTopTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 65
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonFeedsTopTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.userName?.text = feed.getUserName()
            if let profileImageEndpoint = feed.getUserImageUrl(){
                inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: profileImageEndpoint)
            }else{
                cell.profileImage?.image = nil
            }
            cell.dateLabel?.text = feed.getfeedCreationDate()
        }
    }
    
}


