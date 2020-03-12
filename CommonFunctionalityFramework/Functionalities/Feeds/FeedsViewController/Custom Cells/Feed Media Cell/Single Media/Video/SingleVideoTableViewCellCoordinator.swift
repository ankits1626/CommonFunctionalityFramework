//
//  SingleVideoTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class SingleVideoTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return SingleVideoTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 205
    }
    
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? SingleVideoTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.containerView?.addBorders(edges: [.left, .right], color: UIColor.getGeneralBorderColor())
        }
    }
    
}

extension SingleVideoTableViewCellCoordinator : PostEditorCellCoordinatorProtocol{
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? SingleVideoTableViewCell{
            cell.selectionStyle = .none
            cell.containerView?.backgroundColor = .yellow
            cell.removeButton?.isHidden = false
            cell.removeButton?.handleControlEvent(
                event: .touchUpInside, buttonActionBlock: {
                    inputModel.delegate?.removeSelectedMedia(index: 0)
            })
            if let mediaAsset = inputModel.datasource.getTargetPost()?.selectedMediaItems?.first?.asset{
                inputModel.localMediaManager?.fetchImageForAsset(asset: mediaAsset, size: cell.feedVideoImageView!.bounds.size, completion: { (_, fetchedImage) in
                    cell.feedVideoImageView?.image = fetchedImage
                })
            }
           cell.containerView?.addBorders(edges: [.bottom,.left, .right], color: UIColor.getGeneralBorderColor())
        }
    }
    
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        return 205
    }
    
    
}
