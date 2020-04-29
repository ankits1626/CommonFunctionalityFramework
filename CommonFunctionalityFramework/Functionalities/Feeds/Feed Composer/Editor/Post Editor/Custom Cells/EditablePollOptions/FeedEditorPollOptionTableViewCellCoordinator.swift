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
    var indexpathMaps = [Int : IndexPath]()
    private weak var targetTableView : UITableView?
    private let MAX_CHARACTER_LENGTH = 25
    
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        self.delegate = inputModel.delegate
        targetTableView = inputModel.targetTableView
        let targetIndexPath = inputModel.targetIndexpath
        indexpathMaps[targetIndexPath.item] = targetIndexPath
        if let cell = inputModel.targetCell as? FeedEditorPollOptionTableViewCell{
            cell.selectionStyle = .none
            cell.descriptionText?.textContainer.maximumNumberOfLines = 1
            cell.descriptionText?.delegate = self
            cell.descriptionText?.tag = inputModel.targetIndexpath.row
            cell.descriptionText?.placeholder = targetIndexPath.row > 1 ? "Choice \(targetIndexPath.row + 1) (Optional)" : "Choice \(targetIndexPath.row + 1)"
            cell.descriptionText?.tag = targetIndexPath.item
            cell.descriptionText?.placeholderFont = .Body2
            cell.descriptionText?.placeholderColor = UIColor.getPlaceholderTextColor()
            cell.maxCharacterLabel?.text = "(Max \(MAX_CHARACTER_LENGTH) Character)"
            cell.maxCharacterLabel?.textColor = UIColor.getPlaceholderTextColor()
            cell.maxCharacterLabel?.font = .Caption1
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
        toggleMaxCharacterCountPlaceHolderVisibility(identifier: textView.tag)
        delegate?.savePostOption(index: textView.tag, option: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return textView.text.count + (text.count - range.length) <= MAX_CHARACTER_LENGTH
    }
    
    private func toggleMaxCharacterCountPlaceHolderVisibility(identifier: Int){
        if let targetIndexPath = indexpathMaps[identifier],
            let cell = targetTableView?.cellForRow(at: targetIndexPath) as?FeedEditorPollOptionTableViewCell{
            if  let isTextempty = cell.descriptionText?.text.isEmpty{
                cell.maxCharacterLabel?.isHidden = !isTextempty
            }else{
                cell.maxCharacterLabel?.isHidden  = false
            }
        }
    }
}
