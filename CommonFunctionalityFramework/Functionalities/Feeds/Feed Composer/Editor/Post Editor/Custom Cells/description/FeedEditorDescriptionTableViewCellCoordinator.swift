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
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        self.delegate = inputModel.delegate
        targetIndexPath = inputModel.targetIndexpath
        if let cell = inputModel.targetCell as? FeedEditorDescriptionTableViewCell{
            cell.descriptionText?.delegate = self
            cell.descriptionText?.placeholder = "Whats on your mind?"
            cell.descriptionText?.placeholderColor = .gray
            cell.containerView?.addBorders(edges: [.bottom, .left, .right], color: UIColor.getGeneralBorderColor())
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
        delegate?.reloadTextViewContainingRow(indexpath: targetIndexPath)
        delegate?.updatePosTile(title: textView.text)
    }
}
