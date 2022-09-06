//
//  FeedCommentTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 11/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedCommentTableViewCellCoordinator:  FeedCellCoordinatorProtocol{
    
    var cellType: FeedCellTypeProtocol{
        return FeedCommentTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        let targetCell = inputModel.targetTableView.dequeueReusableCell(
        withIdentifier: cellType.cellIdentifier,
        for: inputModel.targetIndexpath)
        if let cell  = targetCell as? FeedCommentTableViewCell{
            let comment = inputModel.datasource.getCommentProvider()?.getComment(inputModel.targetIndexpath.row)
            ASMentionCoordinator.shared.getPresentableMentionText(comment?.getCommentText(), completion: { (attr) in
               cell.commentLabel?.text = nil
               cell.commentLabel?.attributedText = attr
                cell.commentLabel?.font = UIFont.Body1
           })
        }
        return targetCell
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedCommentTableViewCell{
            let comment = inputModel.datasource.getCommentProvider()?.getComment(inputModel.targetIndexpath.row)
            cell.userNameLabel?.text = comment?.getCommentUser().getAuthorName()
            cell.userNameLabel?.font = UIFont.Highlighter2
            cell.userDepartmentLabel?.text = comment?.getCommentDate()
            cell.userDepartmentLabel?.font = .Caption1
            cell.userDepartmentLabel?.textColor = .getSubTitleTextColor()
            ASMentionCoordinator.shared.getPresentableMentionText(comment?.getCommentText(), completion: { (attr) in
               cell.commentLabel?.text = nil
               cell.commentLabel?.attributedText = attr
                cell.commentLabel?.font = UIFont.Body1
           })
            if inputModel.targetIndexpath.row + 1 == (inputModel.datasource.getCommentProvider()?.getNumberOfComments() ?? 0){
                cell.containerView?.addBorders(edges: [.left, .right, .bottom], color: .feedCellBorderColor)
                cell.containerView?.roundCorners(corners: [.bottomRight, .bottomLeft], radius: AppliedCornerRadius.standardCornerRadius)
            }else{
                cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            }
            cell.commentContainer?.backgroundColor = .grayBackGroundColor()
            if let unwrappedComment = comment{
                cell.commentCountConatiner?.isHidden = unwrappedComment.likeCount() == 0
                cell.commentCountLabel?.text = unwrappedComment.presentableLikeCount()
                cell.commentCountLabel?.font = .Caption1
                cell.commentCountLabel?.textColor = .getTitleTextColor()
                if let unwrappedThemeManager = inputModel.themeManager{
                    cell.likeIndicator?.backgroundColor = unwrappedComment.isLikedByMe() ? unwrappedThemeManager.getControlActiveColor() : .controlInactiveColor
                }else{
                    cell.likeIndicator?.backgroundColor = unwrappedComment.isLikedByMe() ? .black : .controlInactiveColor
                }
            }
            if let profileImageEndpoint = comment?.getCommentUser().getAuthorProfileImageUrl(){
                inputModel.mediaFetcher.fetchImageAndLoad(cell.userProfileImage, imageEndPoint: profileImageEndpoint)
            }else{
                cell.userProfileImage?.image = nil
            }
            if let commentId = comment?.getComentId(),
                commentId != -1{
                cell.likeButton?.handleControlEvent(
                    event: .touchUpInside,
                    buttonActionBlock: {
                        inputModel.delegate?.toggleLikeForComment(commentIdentifier: commentId)
                })
            }
            
            if let commentId = comment?.getComentId(),
                commentId != -1{
                cell.editOptionsButton?.handleControlEvent(
                    event: .touchUpInside,
                    buttonActionBlock: {
                        inputModel.delegate?.editComment(commentIdentifier: commentId, chatMessage: comment?.getCommentText() ?? "", commentedByPk: comment?.getCommentUser().getCommentedUserPk() ?? 0)
                })
            }
        }
    }
    
}
