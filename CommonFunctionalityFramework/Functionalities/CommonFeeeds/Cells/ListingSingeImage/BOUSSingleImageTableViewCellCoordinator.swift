//
//  BOUSSingleImageTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSSingleImageTableViewCellCoordinator :  CommonFeedCellCoordinatorProtocol{

    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 102
    }
    
    var cellType: CommonFeedCellTypeProtocol{
        return BOUSSingleImageTableViewCellType()
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? BOUSSingleImageTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            if let mediaItem = feed.getMediaList()?.first,
                let mediaItemEndpoint = mediaItem.getCoverImageUrl(){
                inputModel.mediaFetcher.fetchImageAndLoad(cell.feedImageView, imageEndPoint: mediaItemEndpoint)
            }else{
                cell.feedImageView?.image = nil
            }
//            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
//                cell.containerView?.addBorders(edges: [.left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
//            }else{
//                cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
//            }
            let feedTitle = feed.getStrengthData()
            cell.containerView?.backgroundColor = Rgbconverter.HexToColor(feedTitle["badgeBackgroundColor"] as! String, alpha: 1.0)
            
            cell.imageTapButton?.handleControlEvent(
                event: .touchUpInside,
                buttonActionBlock: {
                    inputModel.delegate?.showMediaBrowser(
                        feedIdentifier: feed.feedIdentifier,
                        scrollToItemIndex: 0
                    )
            })
        }
    }
    
}
