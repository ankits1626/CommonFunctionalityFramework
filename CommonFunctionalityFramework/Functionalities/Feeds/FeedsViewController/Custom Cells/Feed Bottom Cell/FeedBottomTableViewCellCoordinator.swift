//
//  FeedBottomTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedBottomTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return FeedBottomTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 59
    }
    
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedBottomTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.seperator?.backgroundColor = .seperatorColor
            cell.commentsCountLabel?.text = feed.getNumberOfComments()
            cell.commentsCountLabel?.font = UIFont.Caption1
            cell.commentsCountLabel?.textColor = UIColor.getSubTitleTextColor()
            cell.clapsCountLabel?.text = feed.getNumberOfClaps()
            cell.clapsCountLabel?.font = UIFont.Caption1
            cell.clapsCountLabel?.textColor = UIColor.getSubTitleTextColor()
            cell.containerView?.roundCorners(corners: [.bottomLeft, .bottomRight], radius: AppliedCornerRadius.standardCornerRadius)
            cell.containerView?.addBorders(edges: [.bottom, .left, .right], color: .feedCellBorderColor)
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
