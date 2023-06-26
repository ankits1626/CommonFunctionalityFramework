//
//  BOUSAwardLevelNominationTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 30/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSAwardLevelNominationTableViewCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var department: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var nominationTitle : UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        nominationTitle?.text = "Nomination".localized
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
