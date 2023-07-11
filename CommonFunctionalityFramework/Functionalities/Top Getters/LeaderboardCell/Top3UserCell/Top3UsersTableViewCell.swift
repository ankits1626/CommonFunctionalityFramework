//
//  Top3UsersTableViewCell.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import UIKit
import RewardzCommonComponents

class Top3UsersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var firstUserBgColor : UIView?
    @IBOutlet weak var userProfilePic0 : UIImageView?
    @IBOutlet weak var userProfilePicParentView0 : UIView?
    @IBOutlet weak var userRankLabel0 : UILabel?
    @IBOutlet weak var userRankLabelParentView0 : UIView?
    @IBOutlet weak var userFullName0 : UILabel?
    @IBOutlet weak var userDepartment0 : UILabel?
    @IBOutlet weak var userReceivedAppreciation0 : UILabel?
    @IBOutlet weak var crownImage0 : UIImageView?
    
    @IBOutlet weak var secondUserBgColor : UIView?
    @IBOutlet weak var userProfilePic1 : UIImageView?
    @IBOutlet weak var userProfilePicParentView1 : UIView?
    @IBOutlet weak var userRankLabel1 : UILabel?
    @IBOutlet weak var userRankLabelParentView1 : UIView?
    @IBOutlet weak var userFullName1 : UILabel?
    @IBOutlet weak var userDepartment1 : UILabel?
    @IBOutlet weak var userReceivedAppreciation1 : UILabel?
    @IBOutlet weak var crownImage1 : UIImageView?
    
    @IBOutlet weak var thirdUserBgColor : UIView?
    @IBOutlet weak var userProfilePic2 : UIImageView?
    @IBOutlet weak var userProfilePicParentView2 : UIView?
    @IBOutlet weak var userRankLabel2 : UILabel?
    @IBOutlet weak var userRankLabelParentView2 : UIView?
    @IBOutlet weak var userFullName2 : UILabel?
    @IBOutlet weak var userDepartment2 : UILabel?
    @IBOutlet weak var userReceivedAppreciation2 : UILabel?
    @IBOutlet weak var crownImage2 : UIImageView?
    
    @IBOutlet weak var firstUserButton : UIButton?
    @IBOutlet weak var secondUserButton : UIButton?
    @IBOutlet weak var thirdUserButton : UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        firstUserBgColor?.backgroundColor = UIColor.getControlColor().lighter(by: 25)
        secondUserBgColor?.backgroundColor = UIColor.getControlColor().lighter(by: 25)
        thirdUserBgColor?.backgroundColor = UIColor.getControlColor().lighter(by: 25)
        
        firstUserBgColor?.curvedUIBorderedControl(borderColor: UIColor.getControlColor(), borderWidth: 1.0, cornerRadius: 8.0)
        secondUserBgColor?.curvedUIBorderedControl(borderColor: UIColor.getControlColor(), borderWidth: 1.0, cornerRadius: 8.0)
        thirdUserBgColor?.curvedUIBorderedControl(borderColor: UIColor.getControlColor(), borderWidth: 1.0, cornerRadius: 8.0)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
