//
//  FeedBottomTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import Reactions

class FeedBottomTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    @IBOutlet weak var clapsButton : BlockButton?
    @IBOutlet weak var showAllClapsButton : BlockButton?
    @IBOutlet weak var clapsCountLabel : UILabel?
    @IBOutlet weak var clapIndicator : UIImageView?
    @IBOutlet weak var commentsButton : UIButton?
    @IBOutlet weak var commentsCountLabel : UILabel?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var seperator : UIView?
    @IBOutlet weak var reactionView: ReactionButton! {
        didSet {
            reactionView.reactionSelector = ReactionSelector()
            reactionView.config           = ReactionButtonConfig() {
            $0.iconMarging      = 8
            $0.spacing          = 4
            $0.font             = UIFont(name: "HelveticaNeue", size: 14)
            $0.neutralTintColor = UIColor(red: 0.47, green: 0.47, blue: 0.47, alpha: 1)
            $0.alignment        = .left
          }

            reactionView.reactionSelector?.feedbackDelegate = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class FeedBottomTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "FeedBottomTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "FeedBottomTableViewCell", bundle: Bundle(for: FeedBottomTableViewCell.self))
    }
}


extension FeedBottomTableViewCell: ReactionFeedbackDelegate {
  func reactionFeedbackDidChanged(_ feedback: ReactionFeedback?) {
//    feedbackLabel.isHidden = feedback == nil
//
//    feedbackLabel.text = feedback?.localizedString
  }
}

