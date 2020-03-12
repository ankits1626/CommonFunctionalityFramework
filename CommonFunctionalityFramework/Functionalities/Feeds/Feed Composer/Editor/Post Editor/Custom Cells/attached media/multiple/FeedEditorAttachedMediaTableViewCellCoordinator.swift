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
            cell.selectionStyle = .none
            cell.containerView?.addBorders(edges: [.bottom, .left, .right], color: UIColor.getGeneralBorderColor())
            cell.containerView?.curvedCornerControl()
            getMediaCoordinator(inputModel).loadCollectionView(targetCollectionView: cell.mediaCollectionView)
        }
    }
    
    var cellType: FeedCellTypeProtocol{
        return MultipleMediaTableViewCellType()
    }
    
    func removeSelectedMediItem(_ inputModel: PostEditorRemoveAttachedMediaDataModel) {
        cachedMediCollectionCoordinator.removedLocalMedia(index: inputModel.targetIndex)
    }
        
    private var cachedMediCollectionCoordinator  : FeedEditorLocalMediaCollectionCoordinator!//= [IndexPath : FeedEditorLocalMediaCollectionCoordinator]()
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
    
    private func getMediaCoordinator(_ inputModel: PostEditorCellLoadDataModel) -> FeedEditorLocalMediaCollectionCoordinator{
        if let mediaCoordinator = cachedMediCollectionCoordinator{
            return mediaCoordinator
        }else{
            let coordinator = FeedEditorLocalMediaCollectionCoordinator(
                InitFeedEditorLocalMediaCollectionCoordinatorModel(
                    datasource: inputModel.datasource,
                    mediaManager: inputModel.localMediaManager,
                    delegate: inputModel.delegate!)
            )
            
            cachedMediCollectionCoordinator = coordinator
            return coordinator
        }
    }
    
}


