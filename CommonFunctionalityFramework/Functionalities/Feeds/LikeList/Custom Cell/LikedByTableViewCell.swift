//
//  LikedByTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 21/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class LikedByTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage : UIImageView?
    @IBOutlet weak var userName : UILabel?
    @IBOutlet weak var departmentName : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
