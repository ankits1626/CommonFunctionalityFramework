//
//  CommonLikesTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 04/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Reactions

class CommonLikesTableViewCellCoordinator :  CommonFeedCellCoordinatorProtocol{
    var reactionBtn : ReactionButton?
    var cellType: CommonFeedCellTypeProtocol{
        return CommonPressLikeButtonTableViewCellType()
    }
    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 59
    }
    
    private var inputModel : CommonFeedCellLoadDataModel? = nil
    
    
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonPressLikeButtonTableViewCell{
            self.inputModel = inputModel
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.seperator?.backgroundColor = .seperatorColor
            cell.commentsCountLabel?.text = "Comment"
            cell.commentsCountLabel?.font = UIFont.Caption1
            cell.commentsCountLabel?.textColor = UIColor.getSubTitleTextColor()
            cell.clapsCountLabel?.text = feed.getNumberOfClaps()
            cell.clapsCountLabel?.font = UIFont.Caption1
            cell.clapsCountLabel?.textColor = UIColor.getSubTitleTextColor()
            if let unwrappedThemeManager = inputModel.themeManager{
                cell.clapIndicator?.backgroundColor = feed.isClappedByMe() ? unwrappedThemeManager.getControlActiveColor() : .controlInactiveColor
                
                cell.commentsButton?.setImage(unwrappedThemeManager.getThemeSpecificImage("icon_comment_gray"), for: .normal)
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
            
            if feed.getUserReactionType() == 0 {
                cell.reactionView.reaction  = Reaction.facebook.like
            }else if feed.getUserReactionType() == 3 {
                cell.reactionView.reaction  = Reaction.facebook.love
            }else if feed.getUserReactionType() == 6 {
                cell.reactionView.reaction  = Reaction.facebook.haha
            }else if feed.getUserReactionType() == 1 {
                cell.reactionView.reaction  = Reaction.facebook.wow
            }else if feed.getUserReactionType() == 2 {
                cell.reactionView.reaction  = Reaction.facebook.sad
            }else {
                cell.reactionView.reaction  = Reaction.init(id: "", title: "Like", color: .red, icon: UIImage(named: "icon_like_gray")!)
            }
            
            cell.reactionView.addTarget(self, action: #selector(facebookButtonReactionTouchedUpAction(_:)), for: .touchUpInside)
            cell.reactionView.addTarget(self, action: #selector(facebookButtonReactionTouchedUpAction(_:)), for: .valueChanged)
            cell.reactionView.tag = inputModel.targetIndexpath.section
            self.reactionBtn = cell.reactionView
        }
    }
    
    @objc func facebookButtonReactionTouchedUpAction(_ sender: AnyObject) {
        if reactionBtn?.isSelected == false {
            reactionBtn?.reaction   = Reaction.facebook.like
        }
        
        if let feed = inputModel?.datasource.getFeedItem(sender.tag) {
            inputModel?.delegate?.postReaction(feedId: feed.feedIdentifier, reactionType: (reactionBtn?.reaction.id)!)
        }

    }
    
}

