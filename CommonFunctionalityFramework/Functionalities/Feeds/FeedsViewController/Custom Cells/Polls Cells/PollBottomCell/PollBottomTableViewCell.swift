//
//  PollBottomTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PollBottomTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var messageLabel : UILabel?
    @IBOutlet weak var daysLabel : UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


class PollBottomTableViewCelType : FeedCellTypeProtocol{
    var cellIdentifier: String{
        return "PollBottomTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "PollBottomTableViewCell", bundle: Bundle(for: PollSubmitButtonCell.self))
    }
}
