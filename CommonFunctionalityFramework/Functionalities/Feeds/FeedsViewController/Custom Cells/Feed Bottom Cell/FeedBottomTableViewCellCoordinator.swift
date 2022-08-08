//
//  FeedBottomTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import Reactions

class FeedBottomTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    var reactionBtn : ReactionButton?
    var cellType: FeedCellTypeProtocol{
        return FeedBottomTableViewCellType()
       
    }
    
    private var inputModel : FeedCellLoadDataModel? = nil
    var feed : FeedsItemProtocol!
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 56
    }

    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedBottomTableViewCell{
            self.inputModel = inputModel
            feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.seperator?.backgroundColor = .seperatorColor
            cell.commentsCountLabel?.text = feed.getNumberOfComments()
            cell.commentsCountLabel?.font = UIFont.Caption1
            cell.commentsCountLabel?.textColor = UIColor.getSubTitleTextColor()
            cell.clapsCountLabel?.text = feed.getNumberOfClaps()
            cell.clapsCountLabel?.font = UIFont.Caption1
            cell.clapsCountLabel?.textColor = UIColor.getSubTitleTextColor()
            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
                cell.containerView?.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 0)
                cell.containerView?.addBorders(edges: [.bottom, .left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
            }else{
                cell.containerView?.roundCorners(corners: [.bottomLeft, .bottomRight], radius: AppliedCornerRadius.standardCornerRadius)
                cell.containerView?.addBorders(edges: [.bottom, .left, .right], color: .feedCellBorderColor)
            }
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
            
            let reactionType = feed.getUserReactionType()
            if  reactionType == 0 {
                cell.reactionView.reaction  = Reaction.facebook.like
            }else if reactionType == 3 {
                cell.reactionView.reaction  = Reaction.facebook.love
            }else if reactionType == 6 {
                cell.reactionView.reaction  = Reaction.facebook.haha
            }else if reactionType == 1 {
                cell.reactionView.reaction  = Reaction.facebook.wow
            }else if reactionType == 2 {
                cell.reactionView.reaction  = Reaction.facebook.sad
            }else {
                cell.reactionView.reaction  = Reaction.init(id: "", title: "Like", color: .gray, icon: UIImage(named: "icon_like_gray")!)
            }
            
            cell.reactionView.addTarget(self, action: #selector(facebookButtonReactionTouchedUpAction(_:)), for: .touchUpInside)
            cell.reactionView.addTarget(self, action: #selector(facebookButtonReactionTouchedUpAction(_:)), for: .valueChanged)
            cell.reactionView.tag = inputModel.targetIndexpath.section
            self.reactionBtn = cell.reactionView
            
            cell.clapsButton?.handleControlEvent(
                event: .touchUpInside,
                buttonActionBlock: {
                    inputModel.delegate?.toggleClapForPost(feedIdentifier: self.feed.feedIdentifier)
            })
            cell.showAllClapsButton?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {
                inputModel.delegate?.showAllClaps(feedIdentifier: self.feed.feedIdentifier)
            })
        }
    }
    
    @objc func facebookButtonReactionTouchedUpAction(_ sender: AnyObject) {
//        if reactionBtn?.isSelected == false {
//            reactionBtn?.reaction   = Reaction.facebook.like
//        }
        
        let getReactionidType = getReactionIdFromString(reactionType: (reactionBtn?.reaction.id)!)
        inputModel?.delegate?.postReaction(feedId: feed.feedIdentifier, reactionType: "\(getReactionidType)")

    }
    
    func getReactionIdFromString(reactionType: String) -> String {
        if reactionType == "Like" {
            return "0"
        }else if reactionType == "Love" {
            return "3"
        }else if reactionType == "Clap" {
            return "6"
        }else if reactionType == "Celebrate" {
            return "1"
        }else if reactionType == "Support" {
            return "2"
        }else {
            return "0"
        }
    }
}
