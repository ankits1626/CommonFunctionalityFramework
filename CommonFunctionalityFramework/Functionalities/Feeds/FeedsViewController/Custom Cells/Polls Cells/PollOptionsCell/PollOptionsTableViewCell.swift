//
//  PollOptionsTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 13/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PollOptionsTableViewCell: UITableViewCell {
    @IBOutlet weak var optionTitle : UILabel?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var optionContainerView : UIView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class PollOptionsTableViewCellType : FeedCellTypeProtocol{
    var cellIdentifier: String{
        return "PollOptionsTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "PollOptionsTableViewCell", bundle: Bundle(for: PollOptionsTableViewCell.self))
    }
}
