//
//  PostPollTitleTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 14/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import ActiveLabel

class PostPollTitleTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    @IBOutlet weak var feedTitle : ActiveLabel?
    @IBOutlet weak var containerView : UIView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class PostPollTitleTableViewCellType : FeedCellTypeProtocol{
    var cellIdentifier: String{
        return "PostPollTitleTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "PostPollTitleTableViewCell", bundle: Bundle(for: PostPollTitleTableViewCell.self))
    }
}

