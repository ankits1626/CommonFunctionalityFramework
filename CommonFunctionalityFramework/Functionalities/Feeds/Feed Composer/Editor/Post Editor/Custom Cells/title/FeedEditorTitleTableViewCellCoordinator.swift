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
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        self.delegate = inputModel.delegate
        targetIndexPath = inputModel.targetIndexpath
        if let cell = inputModel.targetCell as? FeedEditorTitleTableViewCell{
            cell.titleText?.delegate = self
            cell.titleText?.placeholder = "Title"
            cell.titleText?.placeholderColor = UIColor.getPlaceholderTextColor()
            cell.containerView?.addBorders(edges: [.top, .left, .right], color: UIColor.getGeneralBorderColor())
            cell.containerView?.clipsToBounds = true
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
        delegate?.updatePosTile(title: textView.text)
    }
}
