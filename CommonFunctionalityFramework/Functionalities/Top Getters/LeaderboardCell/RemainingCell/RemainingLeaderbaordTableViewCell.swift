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
        userRankLabelContainer?.curvedUIBorderedControl(borderColor: .white, borderWidth: 1.0, cornerRadius: 8.0 )
        userProfilePic?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0 )
        parentViewContainer?.curvedUIBorderedControl(borderColor: UIColor(red: 237, green: 240, blue: 255), borderWidth: 1.0, cornerRadius: 8.0 )
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
