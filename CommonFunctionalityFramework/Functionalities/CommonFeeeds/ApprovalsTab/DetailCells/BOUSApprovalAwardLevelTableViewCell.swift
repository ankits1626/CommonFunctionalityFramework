//
//  BOUSApprovalAwardLevelTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSApprovalAwardLevelTableViewCell: UITableViewCell {

    @IBOutlet weak var awardType: UILabel!
    @IBOutlet weak var leftImg: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var ptsLbl: UILabel!
    @IBOutlet weak var awardTitleLabel : UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        awardTitleLabel?.text = "Award Level".localized
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
