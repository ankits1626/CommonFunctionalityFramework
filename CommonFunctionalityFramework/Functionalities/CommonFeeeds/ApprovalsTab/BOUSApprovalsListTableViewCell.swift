//
//  BOUSApprovalsListTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 13/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import ActiveLabel

class BOUSApprovalsListTableViewCell: UITableViewCell {

    @IBOutlet weak var usrImg: UIImageView!
    @IBOutlet weak var timeRemaining: UILabel!
    @IBOutlet weak var userStrengthDescription: ActiveLabel!
    @IBOutlet weak var userStrengthTitle: UILabel!
    @IBOutlet weak var nominatedDate: UILabel!
    @IBOutlet weak var nominatedBy: UILabel!
    @IBOutlet weak var nominatedUserName: UILabel!
    @IBOutlet weak var awardThumbnail: UIImageView!
    @IBOutlet weak var awardType: UILabel!
    @IBOutlet weak var awardPoints: UILabel!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userStrengthDescription.hashtagColor = .black
        userStrengthDescription.mentionColor = .black
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
