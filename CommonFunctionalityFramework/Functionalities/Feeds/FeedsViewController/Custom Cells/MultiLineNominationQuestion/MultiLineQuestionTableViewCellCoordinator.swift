//
//  MultiLineQuestionTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 31/01/24.
//  Copyright © 2024 Rewardz. All rights reserved.
//

import UIKit

class MultiLineQuestionTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return MultiLineNominationQuestionTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        let cell = inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: "MultiLineNominationQuestionTableViewCell",
            for: inputModel.targetIndexpath) as! MultiLineNominationQuestionTableViewCell
        let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
        if  let feedNominationData = feed.getUserEnteredAnsers()?[inputModel.targetIndexpath.row - 2] {
            cell.questionansers?.text = feedNominationData.ansers
        }
        
        if feed.getQuestionLabel()[inputModel.targetIndexpath.row - 2].count > 0 {
            cell.questionLabel?.text = feed.getQuestionLabel()[inputModel.targetIndexpath.row - 2]
        }
        return cell
    }

    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        //not required
    }
    
}
