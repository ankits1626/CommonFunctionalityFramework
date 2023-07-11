//
//  RemainingLeaderbaordTableViewCell.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import UIKit

class RemainingLeaderbaordTableViewCell: UITableViewCell {

    @IBOutlet weak var remainingUserButton : UIButton?
    
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
        userRankLabelContainer?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0 )
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
