//
//  BOUSAwardHistoryTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 23/06/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import UIKit

class BOUSAwardHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var awardHistoryLabel : UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        awardHistoryLabel?.text = "Award History".localized
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
