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
        return 110
    }
    var cell: CommonPressLikeButtonTableViewCell!
    private var inputModel : CommonFeedCellLoadDataModel? = nil
    var reactionList: NSArray!
    var image1: Bool?
    var image2: Bool?
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonPressLikeButtonTableViewCell{
            self.inputModel = inputModel
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            self.cell = cell
            cell.reactionCountBtn.handleControlEvent(event: .touchUpInside,   buttonActionBlock: {
                inputModel.delegate?.showPostReactions(
                    feedIdentifier: feed.feedIdentifier
                )
            })
            
            reactionList = feed.getReactionsData()
            if let reactionData = reactionList {
                
                if reactionData.count == 0 {
                    cell.reactionImg1.isHidden = true
                    cell.reactionImg2.isHidden = true
                    cell.reactionCountBtn.isHidden = true
                    self.image1 = false
                }else if reactionData.count > 0 {
                    cell.reactionCountBtn.setTitle("\(reactionData.count)", for: .normal)
                    cell.reactionCountBtn.isHidden = false
                    if let dict1 = reactionData[0] as?  NSDictionary {
                        if let image1 = dict1["reaction_type"] as? Int {
                            cell.reactionImg1.isHidden = false
                            cell.reactionImg1.setImage(UIImage(named: "\(setReactionImageType( reactionType: image1))"), for: .normal)
                            self.image1 = true
                        }else {
                            cell.reactionImg1.isHidden = true
                            self.image1 = false
                        }
                    }
                }else {
                    cell.reactionImg1.isHidden = true
                    self.image1 = false
                }
                
                if reactionData.count > 1 {
                    if let dict2 = reactionData[1] as? NSDictionary {
                        if let image2 = dict2["reaction_type"] as? Int {
                            cell.reactionImg2.isHidden = false
                            cell.reactionImg2.setImage(UIImage(named: "\(setReactionImageType( reactionType: image2))"), for: .normal)
                            self.image2 = true
                        }else {
                            cell.reactionImg2.isHidden = true
                            self.image2 = false
                        }
                    }
                }else {
                    cell.reactionImg2.isHidden = true
                    self.image2 = false
                }
            }
            
            cell.commentsLbl.setTitle("\(feed.getNumberOfComments())", for: .normal)

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
            }else if feed.getUserReactionType() == 1 {
                cell.reactionView.reaction  = Reaction.facebook.love
            }else if feed.getUserReactionType() == 2 {
                cell.reactionView.reaction  = Reaction.facebook.haha
            }else if feed.getUserReactionType() == 3 {
                cell.reactionView.reaction  = Reaction.facebook.wow
            }else if feed.getUserReactionType() == 4 {
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
    
    func setReactionImageType(reactionType: Int) -> String {
        if reactionType == 0 {
            return "icon_React_like"
        }else if reactionType == 3 {
            return "icon_React_love"
        }else if reactionType == 6 {
            return "icon_React_clap"
        }else if reactionType == 1 {
            return "icon_React_celebrate"
        }else if reactionType == 2 {
            return "icon_React_support"
        }else {
            return "Like"
        }
    }
    
    @objc func facebookButtonReactionTouchedUpAction(_ sender: AnyObject) {
//        if reactionBtn?.isSelected == false {
//            reactionBtn?.reaction   = Reaction.facebook.like
//        }
        
        if let feed = inputModel?.datasource.getFeedItem(sender.tag) {
            let getReactionidType = getReactionIdFromString(reactionType: (reactionBtn?.reaction.id)!)
            inputModel?.delegate?.postReaction(feedId: feed.feedIdentifier, reactionType: "\(getReactionidType)")
            cell.reactionCountBtn.setTitle("\(reactionList.count + 1)", for: .normal)
            cell.reactionImg1.isHidden = false
            cell.reactionCountBtn.isHidden = false
            var getImageType = setReactionImageType(reactionType: Int(getReactionidType)!)
            if let isImage1 = image1 {
                if !isImage1 {
                    cell.reactionImg1.setImage(UIImage(named: getImageType), for: .normal)
                }
            }
            
            if let isImage2 = image2 {
                if !isImage2 {
                    cell.reactionImg2.setImage(UIImage(named: getImageType), for: .normal)
                }
            } 
        }
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

