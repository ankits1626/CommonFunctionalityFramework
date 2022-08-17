//
//  SingleImageTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class SingleImageTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return SingleImageTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 140
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? SingleImageTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            if let mediaItem = feed.getMediaList()?.first,
                let mediaItemEndpoint = mediaItem.getCoverImageUrl(){
                inputModel.mediaFetcher.fetchImageAndLoad(cell.feedImageView, imageEndPoint: mediaItemEndpoint)
            }else if let gifItem = feed.getGiphy() {
                if !gifItem.isEmpty {
                    inputModel.mediaFetcher.fetchImageAndLoad(cell.feedImageView, imageEndPoint: URL(string: gifItem))
                }else {
                    cell.feedImageView?.image = nil
                }
            }else{
                cell.feedImageView?.image = nil
            }
            cell.feedImageView?.curvedCornerControl()
            cell.feedImageView?.addBorders(edges: [.left, .right], color: .clear)
//            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
//                cell.containerView?.addBorders(edges: [.left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
//            }else{
//                cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
//            }
            let feedTitle = feed.getStrengthData()
            cell.containerView?.backgroundColor = Rgbconverter.HexToColor(feedTitle["badgeBackgroundColor"] as? String ?? "", alpha: 1.0)
            cell.containerView?.clipsToBounds = true
            cell.containerView?.layer.cornerRadius = 8
            cell.containerView?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
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
