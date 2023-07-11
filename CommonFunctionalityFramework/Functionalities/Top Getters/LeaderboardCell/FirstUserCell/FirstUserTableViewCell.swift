//
//  FirstUserTableViewCell.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import UIKit

class FirstUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var firstUserButton : UIButton?
    
    @IBOutlet weak var userFullName : UILabel?
    @IBOutlet weak var userDepartment : UILabel?
    @IBOutlet weak var userProfilePic : UIImageView?
    @IBOutlet weak var userProfilePicContainer : UIView?
    @IBOutlet weak var userRankLabel : UILabel?
    @IBOutlet weak var userRankLabelContainer : UIView?
    @IBOutlet weak var userAppreciationReceivedLbl : UILabel?
    @IBOutlet weak var parentViewContainer : UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = UIColor.getControlColor()
        contentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
