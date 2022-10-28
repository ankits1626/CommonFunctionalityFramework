//
//  BOUSSingleImageTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSSingleImageTableViewCellCoordinator :  CommonFeedCellCoordinatorProtocol{
    var singleImgHeight = 250.0
    //let serverUrl = UserDefaults.standard.value(forKey: "serviceurl") as? String ?? ""

    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
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
    
//    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
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
//    }

    var cellType: CommonFeedCellTypeProtocol{
        return BOUSSingleImageTableViewCellType()
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? BOUSSingleImageTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            if let mediaItem = feed.getMediaList()?.first,
               let mediaItemEndpoint = mediaItem.getCoverImageUrl(){
                cell.imageTapButton?.isUserInteractionEnabled = true
                inputModel.mediaFetcher.fetchImageAndLoad(cell.feedImageView, imageEndPoint: mediaItemEndpoint)
            }else if let gifItem = feed.getGiphy() {
                if !gifItem.isEmpty {
                    cell.imageTapButton?.isUserInteractionEnabled = false
                    inputModel.mediaFetcher.fetchImageAndLoad(cell.feedImageView, imageEndPoint: URL(string: gifItem))
                }else {
                    cell.imageTapButton?.isUserInteractionEnabled = true
                    cell.feedImageView?.image = nil
                }
            }else{
                cell.imageTapButton?.isUserInteractionEnabled = true
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
    
    func imageDimenssions(url: String) -> CGFloat{
        if let imageSource = CGImageSourceCreateWithURL(URL(string: url)! as CFURL, nil) {
            if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? {
//                let pixelWidth = imageProperties[kCGImagePropertyPixelWidth] as? CGFloat ?? 0.0
                let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as? CGFloat ?? 0.0
                return pixelHeight
            }
        }
        return 0.0
    }
    
}
