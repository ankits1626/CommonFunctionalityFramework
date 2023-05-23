//
//  FeedOrganisationTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents
class FeedOrganisationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var departmentLbl: UILabel?
    @IBOutlet weak var rowContainer: UIView?
    @IBOutlet weak var cellSeperator: UIView?
    @IBOutlet weak var checkBox : ASCheckBox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
