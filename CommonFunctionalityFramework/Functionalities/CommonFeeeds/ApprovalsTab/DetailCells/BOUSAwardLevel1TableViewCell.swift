//
//  BOUSAwardLevel1TableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 30/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSAwardLevel1TableViewCell: UITableViewCell {

    @IBOutlet weak var privacyLevelStackView: UIStackView!
    @IBOutlet weak var awardLevelStackView: UIStackView!
    @IBOutlet weak var userLevelStackView: UIStackView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var department: UILabel!
    @IBOutlet weak var levelNumber: UILabel!
    @IBOutlet weak var leftAwardLevel: UILabel!
    @IBOutlet weak var rightAwardLevel: UILabel!
    @IBOutlet weak var leftPrivacyLevel: UILabel!
    @IBOutlet weak var rightPrivacyLevel: UILabel!
    @IBOutlet weak var awardLevelStatus: UILabel!
    @IBOutlet weak var modificationLabel : UILabel?
    @IBOutlet weak var awardTitleLabel : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        modificationLabel?.text = "Modification".localized
        awardTitleLabel?.text = "Award Level".localized
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
