//
//  SingleImageTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class SingleImageTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return SingleImageTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 205
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? SingleImageTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            if let mediaItem = feed.getMediaList()?.first,
                let mediaItemEndpoint = mediaItem.getCoverImageUrl(){
                inputModel.mediaFetcher.fetchImageAndLoad(cell.feedImageView, imageEndPoint: mediaItemEndpoint)
            }else{
                cell.feedImageView?.image = nil
            }
            cell.containerView?.addBorders(edges: [.left, .right], color: UIColor.getGeneralBorderColor())
            cell.imageTapButton?.handleControlEvent(
                event: .touchUpInside,
                buttonActionBlock: {
                    inputModel.delegate.showMediaBrowser(
                        feedIdentifier: feed.feedIdentifier,
                        scrollToItemIndex: 0
                    )
            })
        }
    }
    
}

//PostEditorCellCoordinatorProtocol
extension SingleImageTableViewCellCoordinator : PostEditorCellCoordinatorProtocol{
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? SingleImageTableViewCell{
            cell.selectionStyle = .none
            cell.containerView?.backgroundColor = .green
            cell.removeButton?.isHidden = false
            cell.removeButton?.handleControlEvent(
                event: .touchUpInside, buttonActionBlock: {
                    inputModel.delegate?.removeSelectedMedia(index: 0)
            })
            if let mediaAsset = inputModel.datasource.getTargetPost()?.selectedMediaItems?.first?.asset{
                inputModel.localMediaManager?.fetchImageForAsset(asset: mediaAsset, size: cell.feedImageView!.bounds.size, completion: { (_, fetchedImage) in
                    cell.feedImageView?.image = fetchedImage
                })
            }
            cell.containerView?.addBorders(edges: [.bottom,.left, .right], color: UIColor.getGeneralBorderColor())
            cell.containerView?.curvedCornerControl()
        }
    }
    
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        return 205
    }
    
    
}
