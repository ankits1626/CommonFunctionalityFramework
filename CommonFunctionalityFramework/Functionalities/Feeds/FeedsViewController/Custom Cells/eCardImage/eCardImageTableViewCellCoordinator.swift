//
//  eCardImageTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 12/07/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//
import UIKit

class eCardImageTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    
    var singleImgHeight = 250.0
    //let serverUrl = UserDefaults.standard.value(forKey: "serviceurl") as? String ?? ""

    var cellType: FeedCellTypeProtocol{
        return eCardImageTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
        if let getEcardUrl = feed.getEcardUrl() {
            if !getEcardUrl.isEmpty {
                return feed.geteCardHeight()
            }else {
                return singleImgHeight
            }
        }else{
            return singleImgHeight
        }
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? eCardImageTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            
            if let getEcardUrl = feed.getEcardUrl(), !getEcardUrl.isEmpty {
                inputModel.mediaFetcher.fetchImageAndLoad(cell.feedImageView, imageWithCompleteURL: getEcardUrl)
            }else{
                cell.feedImageView?.image = nil
            }
            
            cell.feedImageView?.curvedCornerControl()
            cell.feedImageView?.addBorders(edges: [.left, .right], color: .clear)
                                                          
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



