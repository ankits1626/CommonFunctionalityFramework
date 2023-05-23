//
//  BOUSApprovalDescriptionTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import ActiveLabel

class BOUSApprovalDescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl: ActiveLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLbl.hashtagColor = .black
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
