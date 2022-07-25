//
//  LikesSectionTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 04/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Foundation
import Reactions

class LikesSectionTableViewCellCoordinator: CommonFeedCellCoordinatorProtocol{
    
    var cellType: CommonFeedCellTypeProtocol{
        return CommonLikesSectionTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 50
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonLikesSectionTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.reactionCountBtn.handleControlEvent(event: .touchUpInside,   buttonActionBlock: {
                inputModel.delegate?.showPostReactions(
                    feedIdentifier: feed.feedIdentifier
                )
            })
            
            let reactionList = feed.getReactionsData()
            if let reactionData = reactionList {
                cell.reactionCountBtn.setTitle("\(reactionData.count)", for: .normal)
                if reactionData.count > 0 {
                    if let dict1 = reactionData[0] as?  NSDictionary {
                        if let image1 = dict1["reaction_type"] as? Int {
                            cell.reactionImg1.setImage(UIImage(named: "\(setReactionImageType( reactionType: image1))"), for: .normal)
                        }else {
                            cell.reactionImg1.isHidden = true
                        }
                    }
                }

                if reactionData.count > 1 {
                    if let dict2 = reactionData[1] as? NSDictionary {
                        if let image2 = dict2["reaction_type"] as? Int {
                            cell.reactionImg2.setImage(UIImage(named: "\(setReactionImageType( reactionType: image2))"), for: .normal)
                        }else {
                            cell.reactionImg2.isHidden = true
                        }
                    }
                }
            }
            
            cell.commentsLbl.setTitle("\(feed.getNumberOfComments())", for: .normal)
        }
    }
    
    func setReactionImageType(reactionType: Int) -> String {
        if reactionType == 0 {
           return "Like"
       }else if reactionType == 3 {
           return "Like"
       }else if reactionType == 6 {
           return "Like"
       }else if reactionType == 1 {
           return "Like"
       }else if reactionType == 2 {
           return "Love"
       }else {
           return "Like"
       }
    }
    
}




