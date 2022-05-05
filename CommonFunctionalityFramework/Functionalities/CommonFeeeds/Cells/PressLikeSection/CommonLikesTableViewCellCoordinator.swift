//
//  CommonLikesTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 04/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class CommonLikesTableViewCellCoordinator :  CommonFeedCellCoordinatorProtocol{
    
    var cellType: CommonFeedCellTypeProtocol{
        return CommonPressLikeButtonTableViewCellType()
    }
    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 59
    }
    
    
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonPressLikeButtonTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.seperator?.backgroundColor = .seperatorColor
            cell.commentsCountLabel?.text = feed.getNumberOfComments()
            cell.commentsCountLabel?.font = UIFont.Caption1
            cell.commentsCountLabel?.textColor = UIColor.getSubTitleTextColor()
            cell.clapsCountLabel?.text = feed.getNumberOfClaps()
            cell.clapsCountLabel?.font = UIFont.Caption1
            cell.clapsCountLabel?.textColor = UIColor.getSubTitleTextColor()
            if let unwrappedThemeManager = inputModel.themeManager{
                cell.clapIndicator?.backgroundColor = feed.isClappedByMe() ? unwrappedThemeManager.getControlActiveColor() : .controlInactiveColor
                
                cell.commentsButton?.setImage(unwrappedThemeManager.getThemeSpecificImage("feedComments"), for: .normal)
            }else{
                cell.clapsButton?.setImage(
                    UIImage(
                        named: feed.isClappedByMe() ? "clapHands" : "clapHandsNotClappedByMe",
                        in: Bundle(for: FeedBottomTableViewCell.self),
                        compatibleWith: nil),
                    for: .normal
                )
            }
            
            
            cell.clapsButton?.handleControlEvent(
                event: .touchUpInside,
                buttonActionBlock: {
                    inputModel.delegate?.toggleClapForPost(feedIdentifier: feed.feedIdentifier)
            })
            cell.showAllClapsButton?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {
                inputModel.delegate?.showAllClaps(feedIdentifier: feed.feedIdentifier)
            })
        }
    }
    
}

