//
//  FeedEditorDescriptionTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedEditorDescriptionTableViewCellCoordinator: NSObject, PostEditorCellCoordinatorProtocol{
    var delegate : PostEditorCellFactoryDelegate?
    var targetIndexPath : IndexPath = []
    func getCell(_ inputModel: PostEditorCellDequeueModel) -> UITableViewCell {
        let targetCell = inputModel.targetTableView.dequeueReusableCell(
        withIdentifier: cellType.cellIdentifier,
        for: inputModel.targetIndexpath)
        let post = inputModel.datasource.getTargetPost()
        if let cell  = targetCell as? FeedEditorDescriptionTableViewCell{
            cell.descriptionText?.text = post?.postDesciption
        }
        return targetCell
    }
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        self.delegate = inputModel.delegate
        targetIndexPath = inputModel.targetIndexpath
        if let cell = inputModel.targetCell as? FeedEditorDescriptionTableViewCell{
            cell.selectionStyle = .none
            cell.descriptionText?.delegate = self
            cell.descriptionText?.placeholder = "Whats on your mind?"
            cell.descriptionText?.placeholderColor = .gray
            
            if let mediaItems = inputModel.datasource.getTargetPost()?.selectedMediaItems,
            mediaItems.count > 0{
                cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            }
            else{
                cell.containerView?.addBorders(edges: [.bottom,.left, .right], color: .feedCellBorderColor)
                cell.containerView?.curvedCornerControl()
            }
           
            cell.containerView?.clipsToBounds = true
        }
    }
    
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    var cellType: FeedCellTypeProtocol{
        return FeedEditorDescriptionTableViewCellType()
    }
        
}

extension FeedEditorDescriptionTableViewCellCoordinator : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        delegate?.updatePostDescription(decription: textView.text)
        delegate?.reloadTextViewContainingRow(indexpath: targetIndexPath)
    }
}
