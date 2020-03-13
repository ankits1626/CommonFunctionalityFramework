//
//  FeedEditorPollOptionTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 13/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedEditorPollOptionTableViewCellCoordinator: NSObject, PostEditorCellCoordinatorProtocol{
    var delegate : PostEditorCellFactoryDelegate?
    var targetIndexPath : IndexPath = []
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        self.delegate = inputModel.delegate
        targetIndexPath = inputModel.targetIndexpath
        if let cell = inputModel.targetCell as? FeedEditorPollOptionTableViewCell{
            cell.selectionStyle = .none
            cell.descriptionText?.textContainer.maximumNumberOfLines = 1
            cell.descriptionText?.delegate = self
            cell.descriptionText?.tag = inputModel.targetIndexpath.row
            cell.descriptionText?.placeholder = targetIndexPath.row > 1 ? "Choice \(targetIndexPath.row + 1) (Optional)" : "Choice \(targetIndexPath.row + 1)"
            cell.descriptionText?.placeholderColor = .gray
            cell.containerView?.addBorders(edges: [.left, .right], color: UIColor.getGeneralBorderColor())
            cell.containerView?.clipsToBounds = true
        }
    }
    
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        return 50
    }
    
    var cellType: FeedCellTypeProtocol{
        return FeedEditorPollOptionTableViewCellType()
    }
        
}

extension FeedEditorPollOptionTableViewCellCoordinator : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        delegate?.savePostOption(index: textView.tag, option: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
