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
            let comment = inputModel.datasource.getComments()?[inputModel.targetIndexpath.row]
            cell.commentLabel?.text = comment?.getCommentText()
            cell.commentLabel?.font = UIFont.Body1
        }
        return targetCell
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedCommentTableViewCell{
            let comment = inputModel.datasource.getComments()?[inputModel.targetIndexpath.row]
            cell.userNameLabel?.text = comment?.getCommentUser().getUserName()
            cell.userNameLabel?.font = UIFont.Highlighter2
            cell.commentDateLabel?.text = comment?.getCommentDate()
            cell.commentDateLabel?.font = .Caption1
            cell.userDepartmentLabel?.text = comment?.getCommentUser().getUserDepartmentName()
            cell.userDepartmentLabel?.font = UIFont.Caption1
            cell.commentLabel?.text = comment?.getCommentText()
            cell.commentLabel?.font = UIFont.Body1
            if inputModel.targetIndexpath.row + 1 == (inputModel.datasource.getComments()?.count ?? 0){
                cell.containerView?.addBorders(edges: [.left, .right, .bottom], color: UIColor.getGeneralBorderColor())
                cell.containerView?.curvedCornerControl()
            }else{
                cell.containerView?.addBorders(edges: [.left, .right], color: UIColor.getGeneralBorderColor())
            }
            cell.commentContainer?.backgroundColor = .grayBackGroundColor()
            cell.commentContainer?.curvedCornerControl()
        }
    }
    
}
