//
//  FeedEditorTitleTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedEditorTitleTableViewCellCoordinator: NSObject, PostEditorCellCoordinatorProtocol{
    var delegate : PostEditorCellFactoryDelegate?
    var targetIndexPath : IndexPath = []
    
    func getCell(_ inputModel: PostEditorCellDequeueModel) -> UITableViewCell {
        let targetCell = inputModel.targetTableView.dequeueReusableCell(
        withIdentifier: cellType.cellIdentifier,
        for: inputModel.targetIndexpath)
        let post = inputModel.datasource.getTargetPost()
        
        if let cell  = targetCell as? FeedEditorTitleTableViewCell{
            cell.titleText?.text = post?.title
        }
        return targetCell
    }
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        self.delegate = inputModel.delegate
        targetIndexPath = inputModel.targetIndexpath
        let post = inputModel.datasource.getTargetPost()
        if let cell = inputModel.targetCell as? FeedEditorTitleTableViewCell{
            cell.selectionStyle = .none
            cell.titleText?.delegate = self
            switch post!.postType {
            case .Poll:
                cell.titleText?.placeholder = "Ask something"
            case .Post:
                cell.titleText?.placeholder = "Title"
            }
            cell.titleText?.placeholderColor = UIColor.getPlaceholderTextColor()
            cell.containerView?.addBorders(edges: [.top, .left, .right], color: UIColor.getGeneralBorderColor())
            cell.containerView?.clipsToBounds = true
            cell.containerView?.curvedCornerControl()
        }
    }
    
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    var cellType: FeedCellTypeProtocol{
        return FeedEditorTitleTableViewCellType()
    }
    
}

extension FeedEditorTitleTableViewCellCoordinator : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        delegate?.reloadTextViewContainingRow(indexpath: targetIndexPath)
        delegate?.updatePostTile(title: textView.text)
    }
}
