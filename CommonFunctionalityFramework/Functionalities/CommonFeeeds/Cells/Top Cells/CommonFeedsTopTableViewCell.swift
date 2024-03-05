//
//  CommonFeedsTopTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 03/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class CommonFeedsTopTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    @IBOutlet weak var profileImage : UIImageView?
    @IBOutlet weak var userName : UILabel?
    @IBOutlet weak var dateLabel : UILabel?
    @IBOutlet weak var editFeedButton : BlockButton?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var pinPostButton : BlockButton?
    @IBOutlet weak var dot: UIImageView!
    @IBOutlet weak var appraacitedBy: UILabel!
    @IBOutlet weak var pinPostWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var openUserProfileButton : BlockButton?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class CommonFeedsTopTableViewCellType : CommonFeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "CommonFeedsTopTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "CommonFeedsTopTableViewCell", bundle: Bundle(for: CommonFeedsTopTableViewCell.self))
    }
}
