//
//  PostPollLikeTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 15/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class PostPollLikeTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    
    @IBOutlet weak var reactionImg1: UIButton!
    @IBOutlet weak var reactionImg2: UIButton!
    @IBOutlet weak var reactionCountBtn: BlockButton!
    @IBOutlet weak var commentsLbl: UIButton!
    
    @IBOutlet weak var clapsButton : BlockButton?
    @IBOutlet weak var showAllClapsButton : BlockButton?
    @IBOutlet weak var clapsCountLabel : UILabel?
    @IBOutlet weak var clapIndicator : UIImageView?
    @IBOutlet weak var commentsButton : UIButton?
    @IBOutlet weak var commentsCountLabel : UILabel?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var seperator : UIView?
    @IBOutlet weak var reactionView: ReactionButton!
    
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentsCountLabel?.text = "Comment".localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class PostPollLikeTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "PostPollLikeTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "PostPollLikeTableViewCell", bundle: Bundle(for: PostPollLikeTableViewCell.self))
    }
}


extension PostPollLikeTableViewCell: ReactionFeedbackDelegate {
  func reactionFeedbackDidChanged(_ feedback: ReactionFeedback?) {
      
//    feedbackLabel.isHidden = feedback == nil
//
//    feedbackLabel.text = feedback?.localizedString
  }
}

