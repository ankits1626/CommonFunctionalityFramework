//
//  BOUSApprovalPrivacyTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 25/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSApprovalPrivacyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var leftTitle: UILabel!
    @IBOutlet weak var leftDesc: UILabel!
    @IBOutlet weak var tickImg: UIImageView!
    @IBOutlet weak var leftImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
