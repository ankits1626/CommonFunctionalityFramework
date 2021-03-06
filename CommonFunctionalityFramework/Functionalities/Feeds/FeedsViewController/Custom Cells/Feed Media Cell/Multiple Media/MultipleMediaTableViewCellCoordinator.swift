//
//  MultipleMediaTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class MultipleMediaTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return MultipleMediaTableViewCellType()
    }
        
    private var cachedMediCollectionCoordinators = [IndexPath : FeedsMediaCollectionCoordinator]()
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
        if feed.hasOnlyMedia(){
            return 114
        }else{
            switch feed.getMediaCountState() {
                
            case .None:
                return 0
            case .OneMediaItemPresent(_):
                return 0
            case .TwoMediaItemPresent:
                return 122
            case .MoreThanTwoMediItemPresent:
                return 89
            }
        }
        
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? MultipleMediaTableViewCell{
            cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            getMediaCoordinator(inputModel).loadCollectionView(targetCollectionView: cell.mediaCollectionView)
        }
    }
    
    private func getMediaCoordinator(_ inputModel: FeedCellLoadDataModel) -> FeedsMediaCollectionCoordinator{
        if let mediaCoordinator = cachedMediCollectionCoordinators[inputModel.targetIndexpath]{
            return mediaCoordinator
        }else{
            let coordinator = FeedsMediaCollectionCoordinator(
                InitFeedsMediaCollectionCoordinatorModel(
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

