//
//  BOUSMultipleImageTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSMultipleImageTableViewCellCoordinator :  CommonFeedCellCoordinatorProtocol{

    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 140
    }
    
    var cellType: CommonFeedCellTypeProtocol{
        return BOUSMultipleImageTableViewCellType()
    }
    
    private var cachedMediCollectionCoordinators = [IndexPath : CommonFeedsMediaCollectionCoordinator]()
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? BOUSMultipleImageTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
                cell.containerView?.addBorders(edges: [.left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
            }else{
                cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            }
            let feedTitle = feed.getStrengthData()
            cell.containerView?.backgroundColor = Rgbconverter.HexToColor(feedTitle["badgeBackgroundColor"] as! String, alpha: 1.0)
            
            getMediaCoordinator(inputModel).loadCollectionView(targetCollectionView: cell.mediaCollectionView)
        }
    }
    
    private func getMediaCoordinator(_ inputModel: CommonFeedCellLoadDataModel) -> CommonFeedsMediaCollectionCoordinator{
        if let mediaCoordinator = cachedMediCollectionCoordinators[inputModel.targetIndexpath]{
            return mediaCoordinator
        }else{
            let coordinator = CommonFeedsMediaCollectionCoordinator(
                InitCommonFeedsMediaCollectionCoordinatorModel(
                    feedsDatasource: inputModel.datasource,
                    feedItemIndex: inputModel.targetIndexpath.section,
                    mediaFetcher: inputModel.mediaFetcher,
                    delegate: inputModel.delegate
                )
            )
            
            cachedMediCollectionCoordinators[inputModel.targetIndexpath] = coordinator
            return coordinator
        }
    }
    
}
