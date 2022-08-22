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
        return 80
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonFeedsTopTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            
            if inputModel.selectedTab == "received" {
                cell.userName?.text =  "From \(feed.getUserName() ?? "")"
                cell.appraacitedBy.isHidden = true
                cell.dot.isHidden = true
            }else if inputModel.selectedTab == "SearchFromHome" {
                cell.userName?.text = feed.getUserName()
                if let nominatedName = feed.getNominatedByUserName() {
                    cell.appraacitedBy.text = "From \(nominatedName)"
                }
            }else {
                if let toUserName = feed.toUserName() {
                    cell.userName?.text = "To \(toUserName)"
                    cell.appraacitedBy.isHidden = true
                    cell.dot.isHidden = true
                }
            }
            
            if let profileImageEndpoint = feed.getUserImageUrl(){
                inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: profileImageEndpoint)
            }else{
                cell.profileImage?.setImageForName(feed.getUserName() ?? "NN", circular: false, textAttributes: nil)
            }
            cell.dateLabel?.text = feed.getfeedCreationMonthYear()
            if !inputModel.datasource.shouldShowMenuOptionForFeed(){
                cell.editFeedButton?.isHidden = true
            }else{
                cell.editFeedButton?.isHidden = !feed.isActionsAllowed()
            }
            cell.editFeedButton?.handleControlEvent(
                event: .touchUpInside,
                buttonActionBlock: {
                    inputModel.delegate?.showFeedEditOptions(
                        targetView: cell.editFeedButton,
                        feedIdentifier: feed.feedIdentifier
                    )
                })
        }
    }
    
}


