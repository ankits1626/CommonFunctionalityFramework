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
    var numberOfRows:Int!
    
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        self.delegate = inputModel.delegate
        targetTableView = inputModel.targetTableView
        let targetIndexPath = inputModel.targetIndexpath
        indexpathMaps[targetIndexPath.item] = targetIndexPath
        if let cell = inputModel.targetCell as? FeedEditorPollOptionTableViewCell{
            cell.selectionStyle = .none
            //cell.descriptionText?.borderedControl()
//            cell.descriptionText?.layer.borderColor = #colorLiteral(red: 0.9294112921, green: 0.9411767125, blue: 0.9999989867, alpha: 1)
//            cell.descriptionText?.layer.borderWidth = 1.0
//            cell.descriptionText?.layer.masksToBounds
            cell.containerView?.layer.masksToBounds = true
            cell.containerView?.layer.borderColor = #colorLiteral(red: 0.9294112921, green: 0.9411767125, blue: 0.9999989867, alpha: 1)
            cell.containerView?.layer.borderWidth = 1.0
            cell.containerView?.layer.cornerRadius = 8.0
            cell.descriptionText?.textContainer.maximumNumberOfLines = 1
            cell.descriptionText?.delegate = self
            cell.descriptionText?.tag = inputModel.targetIndexpath.row
            cell.descriptionText?.placeholder = targetIndexPath.row > 1 ? " \("+ Add Option".localized) \("(Optional)".localized)" : "\("+ Add Option".localized) \(targetIndexPath.row + 1)"
            numberOfRows = inputModel.targetTableView?.numberOfRows(inSection: 1)
            cell.descriptionText?.tag = targetIndexPath.item
            cell.descriptionText?.placeholderFont = .Body2
            cell.descriptionText?.placeholderColor = UIColor.getPlaceholderTextColor()
            cell.maxCharacterLabel?.textColor = UIColor.getPlaceholderTextColor()
            cell.maxCharacterLabel?.font = .Caption1
            //cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            //cell.containerView?.clipsToBounds = true
            updateMaxCharacterlabel(cell: cell)
           // cell.containerView?.isHidden = true
        }
    }
    
    private func updateMaxCharacterlabel(cell: FeedEditorPollOptionTableViewCell){
        let length = cell.descriptionText?.text.count ?? 0
        if length == 0{
            cell.maxCharacterLabel?.text = "(\("Max".localized) \(MAX_CHARACTER_LENGTH) \("Char".localized))"
        }else{
            cell.maxCharacterLabel?.text = "\(MAX_CHARACTER_LENGTH - length)"
        }
    }
    
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        return 64
    }
    
    var cellType: FeedCellTypeProtocol{
        return FeedEditorPollOptionTableViewCellType()
    }
        
}

extension FeedEditorPollOptionTableViewCellCoordinator : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        //toggleMaxCharacterCountPlaceHolderVisibility(identifier: textView.tag)
        updateCharactersLeft(identifier: textView.tag)
        delegate?.savePostOption(index: textView.tag, option: textView.text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if numberOfRows < 4 && textView.tag >= numberOfRows - 1 {
            delegate?.numberOfRowsIncrement(number: numberOfRows + 1)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return textView.text.count + (text.count - range.length) <= MAX_CHARACTER_LENGTH
    }
    
    private func updateCharactersLeft(identifier: Int){
        if let targetIndexPath = indexpathMaps[identifier],
            let cell = targetTableView?.cellForRow(at: targetIndexPath) as? FeedEditorPollOptionTableViewCell{
            updateMaxCharacterlabel(cell: cell)
        }
    }
}
