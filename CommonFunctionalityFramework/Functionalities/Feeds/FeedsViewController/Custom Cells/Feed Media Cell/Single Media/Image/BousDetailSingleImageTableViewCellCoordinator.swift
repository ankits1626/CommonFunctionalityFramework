//
//  BousDetailSingleImageTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 09/09/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BousDetailSingleImageTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    
    var singleImgHeight = 250.0
    //let serverUrl = UserDefaults.standard.value(forKey: "serviceurl") as? String ?? ""

    var cellType: FeedCellTypeProtocol{
        return SingleImageTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
        if let getEcardUrl = feed.getEcardUrl() {
            if !getEcardUrl.isEmpty {
                return feed.geteCardHeight()
            }else {
                return singleImgHeight
            }
        }
        if let mediaItem = feed.getMediaList()?.first,
           let mediaItemEndpoint = mediaItem.getCoverImageUrl(){
            return feed.getSingleImageHeight()
        }else if let gifItem = feed.getGiphy() {
            if !gifItem.isEmpty {
                return feed.getGifImageHeight()
            }else {
                return singleImgHeight
            }
        }else{
            return singleImgHeight
        }
    }
    
//    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
//        let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
//        if let getEcardUrl = feed.getEcardUrl() {
//            if !getEcardUrl.isEmpty {
//                let ecardHeight = FTImageSize.shared.getImageSize(serverUrl+getEcardUrl)
//                return ecardHeight.height
//            }else {
//                return singleImgHeight
//            }
//        }
//        if let mediaItem = feed.getMediaList()?.first,
//           let mediaItemEndpoint = mediaItem.getCoverImageUrl(){
//            let singleImageHeight = FTImageSize.shared.getImageSize(serverUrl+mediaItemEndpoint)
//            return singleImageHeight.height
//        }else if let gifItem = feed.getGiphy() {
//            if !gifItem.isEmpty {
//                let gifImageHeight = FTImageSize.shared.getImageSize(gifItem)
//                return gifImageHeight.height
//            }else {
//                return singleImgHeight
//            }
//        }else{
//            return singleImgHeight
//        }
//
//
//    }
    
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
            let feedTitle = feed.getStrengthData()
            let backGroundColor = feedTitle["badgeBackgroundColor"] as? String ?? ""
            let backGroundColorLite = feedTitle["background_color_lite"] as? String ?? ""
            if let bgColor = UIColor(hex: backGroundColorLite) {
                cell.containerView?.backgroundColor = bgColor
            }else{
                cell.containerView?.backgroundColor = Rgbconverter.HexToColor(backGroundColorLite)
            }
                                                          
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


