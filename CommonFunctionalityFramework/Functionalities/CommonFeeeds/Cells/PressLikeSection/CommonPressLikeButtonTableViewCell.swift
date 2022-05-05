//
//  CommonPressLikeButtonTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 04/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class CommonPressLikeButtonTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    @IBOutlet weak var clapsButton : BlockButton?
    @IBOutlet weak var showAllClapsButton : BlockButton?
    @IBOutlet weak var clapsCountLabel : UILabel?
    @IBOutlet weak var clapIndicator : UIImageView?
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

class CommonPressLikeButtonTableViewCellType : CommonFeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "CommonPressLikeButtonTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "CommonPressLikeButtonTableViewCell", bundle: Bundle(for: CommonPressLikeButtonTableViewCell.self))
    }
}
