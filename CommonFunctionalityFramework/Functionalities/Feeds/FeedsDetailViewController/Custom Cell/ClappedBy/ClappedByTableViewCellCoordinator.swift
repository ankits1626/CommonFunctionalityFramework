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
        return 50
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? ClappedByTableViewCell{
            cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
//            cell.seeAllButton?.handleControlEvent(
//                event: .touchUpInside,
//                buttonActionBlock: {
//                    inputModel.delegate?.showLikedByUsersList()
//            })
            
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            
            cell.seeAllButton?.handleControlEvent(event: .touchUpInside,   buttonActionBlock: {
                inputModel.delegate?.showPostReactions()
            })
            
            
            cell.clappedByUsers?.forEach({ (aView) in
                aView.isHidden = true
                aView.curvedCornerControl()
            })
            if let clappedUsers = inputModel.datasource.getClappedByUsers(){
                let firstFiveUsers = clappedUsers.prefix(8)
                for (index, clappedByUser) in firstFiveUsers.enumerated() {
                    if let imageView = cell.clappedByUsers?.get(index: index){
                        if let profileImage = clappedByUser.getAuthorProfileImageUrl(){
                            imageView.isHidden = false
                            inputModel.mediaFetcher.fetchImageAndLoad(
                                imageView,
                                imageEndPoint: profileImage)
                        }else{
                            imageView.isHidden = true
                            imageView.image = nil
                        }
                    }
                }
            }
        }
    }
    
}
