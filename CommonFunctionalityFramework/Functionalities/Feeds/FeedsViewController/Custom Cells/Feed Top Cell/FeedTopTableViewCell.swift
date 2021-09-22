//
//  FeedTopTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedTopTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    @IBOutlet weak var profileImage : UIImageView?
    @IBOutlet weak var userName : UILabel?
    @IBOutlet weak var departmentName : UILabel?
    @IBOutlet weak var dateLabel : UILabel?
    @IBOutlet weak var editFeedButton : BlockButton?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var pinPostButton : BlockButton?
    @IBOutlet weak var pinPostWidthConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class FeedTopTableViewCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "SingleMediaFeedsPostTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "FeedTopTableViewCell", bundle: Bundle(for: FeedTopTableViewCell.self))
    }
}

