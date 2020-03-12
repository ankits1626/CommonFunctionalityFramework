//
//  FeedEditorAttachedMediaTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit


class FeedEditorAttachedMutipleMediaTableViewCellCoordinator :  PostEditorCellCoordinatorProtocol{
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        return 122
    }
    
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? MultipleMediaTableViewCell{
            cell.containerView?.addBorders(edges: [.left, .right], color: UIColor.getGeneralBorderColor())
            getMediaCoordinator(inputModel).loadCollectionView(targetCollectionView: cell.mediaCollectionView)
        }
    }
    
    var cellType: FeedCellTypeProtocol{
        return MultipleMediaTableViewCellType()
    }
        
    private var cachedMediCollectionCoordinators = [IndexPath : FeedEditorLocalMediaCollectionCoordinator]()
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
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
    
    
//    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
//        if let cell  = inputModel.targetCell as? MultipleMediaTableViewCell{
//            cell.containerView?.addBorders(edges: [.left, .right], color: UIColor.getGeneralBorderColor())
//            getMediaCoordinator(inputModel).loadCollectionView(targetCollectionView: cell.mediaCollectionView)
//        }
//    }
    
    private func getMediaCoordinator(_ inputModel: PostEditorCellLoadDataModel) -> FeedEditorLocalMediaCollectionCoordinator{
        if let mediaCoordinator = cachedMediCollectionCoordinators[inputModel.targetIndexpath]{
            return mediaCoordinator
        }else{
            let coordinator = FeedEditorLocalMediaCollectionCoordinator(
                InitFeedEditorLocalMediaCollectionCoordinatorModel(
                    datasource: inputModel.datasource,
                    mediaManager: inputModel.localMediaManager)
            )
            
            cachedMediCollectionCoordinators[inputModel.targetIndexpath] = coordinator
            return coordinator
        }
    }
    
}


