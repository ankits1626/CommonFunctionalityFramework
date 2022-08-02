//
//  BOUSMultipleImageTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSMultipleImageTableViewCellCoordinator :  CommonFeedCellCoordinatorProtocol, MultipleImageFlowLayoutDelegate{
    func currentPageSelected(currentPage: Int) {
        print(currentPage)
    }
    

    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 190
    }
    
    var cellType: CommonFeedCellTypeProtocol{
        return BOUSMultipleImageTableViewCellType()
    }
    
    private var cachedMediCollectionCoordinators = [IndexPath : CommonFeedsMediaCollectionCoordinator]()
    var currentSwipePage : Int = 0
    
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
            //cell.containerView.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
            cell.mediaCollectionView.decelerationRate = .fast
            (cell.mediaCollectionView?.collectionViewLayout as! MultipleImageFlowLayout).pageCollectionLayoutDelegate = self

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
