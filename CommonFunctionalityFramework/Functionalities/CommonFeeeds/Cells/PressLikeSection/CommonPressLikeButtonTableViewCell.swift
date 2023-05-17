//
//  CommonPressLikeButtonTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 04/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Reactions

class CommonPressLikeButtonTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
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
        reactionView.addTarget(self, action: #selector(facebookButtonReactionTouchedUpAction(_:)), for: .touchUpInside)
    }
    
    @IBAction func facebookButtonReactionTouchedUpAction(_ sender: AnyObject) {
        print(reactionView.reaction.id)

      if reactionView.isSelected == false {
        reactionView.reaction   = Reaction.facebook.like
      }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class CommonPressLikeButtonTableViewCellType : CommonFeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "CommonPressLikeButtonTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "CommonPressLikeButtonTableViewCell", bundle: Bundle(for: CommonPressLikeButtonTableViewCell.self))
    }
}


extension CommonPressLikeButtonTableViewCell: ReactionFeedbackDelegate {
  func reactionFeedbackDidChanged(_ feedback: ReactionFeedback?) {
//    feedbackLabel.isHidden = feedback == nil
//
//    feedbackLabel.text = feedback?.localizedString
  }
}
