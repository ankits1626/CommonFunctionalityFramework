//
//  FeedEditorTitleTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedEditorTitleTableViewCellCoordinator: NSObject, PostEditorCellCoordinatorProtocol{
    weak var delegate : PostEditorCellFactoryDelegate?
    var targetIndexPath : IndexPath = []
    private weak var targetTableView : UITableView?
    private let POST_MAX_CHARACTER_LENGTH = 80
    private let POLL_MAX_CHARACTER_LENGTH = 200
    private var max_title_length = 0
    func getCell(_ inputModel: PostEditorCellDequeueModel) -> UITableViewCell {
        targetTableView = inputModel.targetTableView
        let targetCell = inputModel.targetTableView.dequeueReusableCell(
        withIdentifier: cellType.cellIdentifier,
        for: inputModel.targetIndexpath)
        let post = inputModel.datasource?.getTargetPost()
        
        if let cell  = targetCell as? FeedEditorTitleTableViewCell{
            cell.titleText?.text = post?.title
            updateMaxCharacterLabel(cell)
        }
        return targetCell
    }
    fileprivate func updateMaxCharacterLabel(_ cell: FeedEditorTitleTableViewCell) {
        let length = cell.titleText?.text.count ?? 0
        if length == 0{
            cell.maxCharacterLabel?.text = "(\("Max".localized) \(max_title_length) \("Characters".localized))"
        }else{
            cell.maxCharacterLabel?.text = "\(max_title_length - (cell.titleText?.text.count ?? 0))"
        }
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
                cell.titleText?.placeholder = "Ask something".localized
                max_title_length = POLL_MAX_CHARACTER_LENGTH
            case .Post:
                cell.titleText?.placeholder = "Title".localized
                cell.titleText?.font = .SemiBold14
                max_title_length = POST_MAX_CHARACTER_LENGTH
            }
            cell.titleText?.placeholderColor = UIColor.getPlaceholderTextColor()
            cell.titleText?.placeholderFont = .Body2
            cell.maxCharacterLabel?.textColor = UIColor.getPlaceholderTextColor()
            cell.maxCharacterLabel?.font = .Caption1
            cell.containerView?.addBorders(edges: [.top, .left, .right], color: .feedCellBorderColor)
            cell.containerView?.clipsToBounds = true
            cell.containerView?.curvedCornerControl()
            updateMaxCharacterLabel(cell)
        }
    }
    
    private func updateCharactersLeft(){
        if let cell = targetTableView?.cellForRow(at: targetIndexPath) as?FeedEditorTitleTableViewCell{
            updateMaxCharacterLabel(cell)
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
        delegate?.updatePostTitle(title: textView.text)
        delegate?.reloadTextViewContainingRow(indexpath: targetIndexPath)
        updateCharactersLeft()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= max_title_length
    }
}
