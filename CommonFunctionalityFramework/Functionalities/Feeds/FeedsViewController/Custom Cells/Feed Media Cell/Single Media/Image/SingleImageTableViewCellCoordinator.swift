//
//  SingleImageTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class SingleImageTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    
    var singleImgHeight = 250.0
    let serverUrl = UserDefaults.standard.value(forKey: "serviceurl") as? String ?? ""

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
//            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
//                cell.containerView?.addBorders(edges: [.left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
//            }else{
//                cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
//            }
            let feedTitle = feed.getStrengthData()
            cell.contentView.backgroundColor = .white
            cell.containerView?.backgroundColor = .white
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

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
