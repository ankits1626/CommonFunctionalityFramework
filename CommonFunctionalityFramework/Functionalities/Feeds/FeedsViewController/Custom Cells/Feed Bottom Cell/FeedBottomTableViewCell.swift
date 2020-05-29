//
//  FeedBottomTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedBottomTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    @IBOutlet weak var clapsButton : BlockButton?
    @IBOutlet weak var showAllClapsButton : BlockButton?
    @IBOutlet weak var clapsCountLabel : UILabel?
    @IBOutlet weak var commentsButton : UIButton?
    @IBOutlet weak var commentsCountLabel : UILabel?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var seperator : UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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


