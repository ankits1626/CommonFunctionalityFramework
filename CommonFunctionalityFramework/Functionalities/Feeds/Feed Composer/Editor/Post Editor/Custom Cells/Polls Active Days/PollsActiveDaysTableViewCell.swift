//
//  PollsActiveDaysTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 29/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PollsActiveDaysTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var activeDaysLabel : UILabel?
    @IBOutlet weak var activeDaysStepper : Stepper?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activeDaysStepper?.minVal = 1
        activeDaysStepper?.maxVal = 30
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class PollsActiveDaysTableViewCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "PollsActiveDaysTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "PollsActiveDaysTableViewCell", bundle: Bundle(for: PollsActiveDaysTableViewCell.self))
    }
}
