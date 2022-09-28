//
//  BOUSTwoImageDetailCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 28/09/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSTwoImageDetailCoordinator :  FeedCellCoordinatorProtocol{
    
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 176
    }
    
    var cellType: FeedCellTypeProtocol{
        return BOUSTwoImageDetailTableViewCellType()
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? BOUSTwoImageDetailTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            
            if let mediaItem = feed.getMediaList()?.first,
               let mediaItemEndpoint = mediaItem.getCoverImageUrl(){
                inputModel.mediaFetcher.fetchImageAndLoad(cell.feedImageView1, imageEndPoint: mediaItemEndpoint)
               
            }else if let gifItem = feed.getGiphy() {
                if !gifItem.isEmpty {
                    inputModel.mediaFetcher.fetchImageAndLoad(cell.feedImageView1, imageEndPoint: URL(string: gifItem))
                }else {
                    cell.feedImageView1?.image = nil
                    cell.feedImageView2?.image = nil
                }
            }else{
                cell.feedImageView1?.image = nil
                cell.feedImageView2?.image = nil
            }
            
            if let mediaItem2 = feed.getMediaList()?.last,
               let mediaItemEndpoint2 = mediaItem2.getCoverImageUrl(){
                inputModel.mediaFetcher.fetchImageAndLoad(cell.feedImageView2, imageEndPoint: mediaItemEndpoint2)
            }
            
            
            cell.feedImageView1?.curvedCornerControl()
            cell.feedImageView1?.addBorders(edges: [.left, .right], color: .clear)
            cell.feedImageView2?.curvedCornerControl()
            cell.feedImageView2?.addBorders(edges: [.left, .right], color: .clear)
            //            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
            //                cell.containerView?.addBorders(edges: [.left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
            //            }else{
            //                cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            //            }
            
            
            let feedTitle = feed.getStrengthData()
            let backGroundColor = feedTitle["badgeBackgroundColor"] as? String ?? ""
            let backGroundColorLite = feedTitle["background_color_lite"] as? String ?? ""
            if let bgColor = UIColor(hex: backGroundColorLite) {
                cell.containerView?.backgroundColor = bgColor
            }else{
                cell.containerView?.backgroundColor = Rgbconverter.HexToColor(backGroundColorLite)
            }

            
            
            cell.imageTapButton?.handleControlEvent(
                event: .touchUpInside,
                buttonActionBlock: {
                    inputModel.delegate?.showMediaBrowser(
                        feedIdentifier: feed.feedIdentifier,
                        scrollToItemIndex: 0
                    )
                })
            
            cell.containerView?.clipsToBounds = true
            cell.containerView?.layer.cornerRadius = 8
            cell.containerView?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            
        }
    }
    
}
