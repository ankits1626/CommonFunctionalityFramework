//
//  PollOptionsVotedTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PollOptionsVotedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var optionTitle : UILabel?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var optionContainerView : UIView?
    @IBOutlet weak var myOptionIndicator : UIImageView?
    @IBOutlet weak var percentageVote : UILabel?
    @IBOutlet weak var circleLbl: UILabel!
    @IBOutlet weak var percentageVoteIndicator : UIProgressView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


class PollOptionsVotedTableViewCellType : FeedCellTypeProtocol{
    var cellIdentifier: String{
        return "PollOptionsVotedTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "PollOptionsVotedTableViewCell", bundle: Bundle(for: PollOptionsTableViewCell.self))
    }
}
