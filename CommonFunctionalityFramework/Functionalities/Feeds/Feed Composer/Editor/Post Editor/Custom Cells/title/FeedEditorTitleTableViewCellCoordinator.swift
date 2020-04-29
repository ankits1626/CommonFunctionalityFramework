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
    private weak var targetTableView : UITableView?
    private let MAX_CHARACTER_LENGTH = 80
    
    func getCell(_ inputModel: PostEditorCellDequeueModel) -> UITableViewCell {
        targetTableView = inputModel.targetTableView
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
            cell.titleText?.placeholderFont = .Body2
            cell.maxCharacterLabel?.textColor = UIColor.getPlaceholderTextColor()
            cell.maxCharacterLabel?.font = .Caption1
            cell.maxCharacterLabel?.text = "(Max \(MAX_CHARACTER_LENGTH) Character)"
            //cell.maxCharacterLabel?.isHidden = cell.titleText?.text.isEmpty ?? false
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
        toggleMaxCharacterCountPlaceHolderVisibility()
        delegate?.reloadTextViewContainingRow(indexpath: targetIndexPath)
        delegate?.updatePostTitle(title: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= MAX_CHARACTER_LENGTH
    }
    
    private func toggleMaxCharacterCountPlaceHolderVisibility(){
        if let cell = targetTableView?.cellForRow(at: targetIndexPath) as?FeedEditorTitleTableViewCell{
            if  let isTextempty = cell.titleText?.text.isEmpty{
                cell.maxCharacterLabel?.isHidden = !isTextempty
            }else{
                cell.maxCharacterLabel?.isHidden  = false
            }
        }
    }
}
