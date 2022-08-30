//
//  BOUSApprovalHeaderTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSApprovalHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var leftImg: UIImageView!
    @IBOutlet weak var leftName: UILabel!
    @IBOutlet weak var rightName: UILabel!
    @IBOutlet weak var privacyImg: UIImageView!
    @IBOutlet weak var privacyTitle: UILabel!
    @IBOutlet weak var rightImg: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var rightArrowImg: UIImageView!
    @IBOutlet weak var accessLevelTapped: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
